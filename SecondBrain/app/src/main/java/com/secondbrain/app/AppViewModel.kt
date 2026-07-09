package com.secondbrain.app

import android.app.Application
import android.speech.tts.TextToSpeech
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.secondbrain.app.ai.ClaudeClient
import com.secondbrain.app.ai.ContextBuilder
import com.secondbrain.app.data.Repository
import com.secondbrain.app.data.Settings
import com.secondbrain.app.notify.Reminders
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

class AppViewModel(application: Application) : AndroidViewModel(application) {

    val repository = Repository(application)
    val settings = Settings(application)

    private val claude = ClaudeClient { settings.apiKey }

    private val _isThinking = MutableStateFlow(false)
    val isThinking: StateFlow<Boolean> = _isThinking

    private val _autoSpeak = MutableStateFlow(settings.autoSpeak)
    val autoSpeak: StateFlow<Boolean> = _autoSpeak

    private var tts: TextToSpeech? = null
    private var ttsReady = false

    init {
        Reminders.createChannel(application)
        repository.pruneReminders()
        tts = TextToSpeech(application) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale("pt", "BR")
                ttsReady = true
            }
        }
        if (repository.chat.value.isEmpty()) {
            repository.addChatMessage(
                "assistant",
                "Oi! Eu sou o seu segundo cérebro. 🧠\n\nPosso conversar com você, guardar suas tarefas, seu diário e lembrar de tudo que importa na sua vida. Para começar, me conta: como foi seu dia?"
            )
        }
    }

    fun toggleAutoSpeak() {
        val newValue = !_autoSpeak.value
        _autoSpeak.value = newValue
        settings.autoSpeak = newValue
        if (!newValue) tts?.stop()
    }

    fun sendMessage(text: String) {
        val trimmed = text.trim()
        if (trimmed.isEmpty() || _isThinking.value) return

        repository.addChatMessage("user", trimmed)

        if (settings.apiKey.isBlank()) {
            repository.addChatMessage(
                "assistant",
                "Antes de conversarmos, configure sua chave de API da Anthropic na aba Ajustes. Você cria uma em console.anthropic.com → API Keys."
            )
            return
        }

        _isThinking.value = true
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val system = ContextBuilder.build(
                    userName = settings.userName,
                    memories = repository.memories.value,
                    tasks = repository.tasks.value,
                    diary = repository.diary.value
                )
                val reply = claude.chat(system, buildHistory(), ::executeTool)
                repository.addChatMessage("assistant", reply)
                if (_autoSpeak.value) speak(reply)
            } catch (e: Exception) {
                repository.addChatMessage("assistant", "⚠️ Não consegui responder: ${e.message}")
            } finally {
                _isThinking.value = false
            }
        }
    }

    /** Histórico para a API: turnos de texto, começando com uma mensagem do usuário. */
    private fun buildHistory(): List<Pair<String, String>> {
        val all = repository.chat.value
            .filter { it.role == "user" || it.role == "assistant" }
            .takeLast(40)
        val firstUser = all.indexOfFirst { it.role == "user" }
        if (firstUser < 0) return emptyList()
        return all.drop(firstUser).map { it.role to it.text }
    }

    private fun executeTool(name: String, input: JSONObject): String = when (name) {
        "create_task" -> {
            val task = repository.addTask(
                title = input.getString("title"),
                due = input.optString("due").ifBlank { null }
            )
            "Tarefa criada com id ${task.id}."
        }

        "complete_task" -> {
            val task = repository.completeTask(input.getString("id"))
            if (task != null) "Tarefa \"${task.title}\" concluída." else "Tarefa não encontrada."
        }

        "delete_task" -> {
            if (repository.deleteTask(input.getString("id"))) "Tarefa apagada." else "Tarefa não encontrada."
        }

        "add_diary_entry" -> {
            val mood = if (input.has("mood") && !input.isNull("mood")) input.getInt("mood") else null
            repository.addDiaryEntry(input.getString("text"), mood)
            "Entrada registrada no diário."
        }

        "save_memory" -> {
            repository.addMemory(
                content = input.getString("content"),
                category = input.optString("category").ifBlank { "geral" }
            )
            "Memória salva."
        }

        "delete_memory" -> {
            if (repository.deleteMemory(input.getString("id"))) "Memória apagada." else "Memória não encontrada."
        }

        "set_reminder" -> {
            val message = input.getString("message")
            val raw = input.getString("datetime")
            val triggerAt = parseLocalDateTime(raw)
            if (triggerAt == null) {
                "Não entendi a data \"$raw\". Use o formato 2026-07-10T09:00."
            } else if (triggerAt <= System.currentTimeMillis()) {
                "Esse horário já passou. Peça um horário futuro."
            } else {
                val reminder = repository.addReminder(message, triggerAt)
                Reminders.schedule(getApplication<Application>(), reminder.id, message, triggerAt)
                "Lembrete agendado para $raw."
            }
        }

        else -> "Ferramenta desconhecida: $name"
    }

    private fun parseLocalDateTime(raw: String): Long? = try {
        val normalized = raw.trim().take(16) // aceita "2026-07-10T09:00:00" cortando os segundos
        val local = LocalDateTime.parse(normalized, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        local.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
    } catch (e: Exception) {
        null
    }

    fun speak(text: String) {
        if (!ttsReady) return
        // remove emojis/símbolos que soam mal no TTS
        val clean = text.replace(Regex("[\\p{So}\\p{Cn}]"), "").trim()
        if (clean.isNotEmpty()) {
            tts?.speak(clean, TextToSpeech.QUEUE_FLUSH, null, "reply")
        }
    }

    fun stopSpeaking() {
        tts?.stop()
    }

    override fun onCleared() {
        tts?.shutdown()
        super.onCleared()
    }
}
