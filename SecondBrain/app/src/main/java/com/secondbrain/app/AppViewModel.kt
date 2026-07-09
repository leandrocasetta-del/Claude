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
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

class AppViewModel(application: Application) : AndroidViewModel(application) {

    companion object {
        /** Limite de caracteres por mensagem para evitar custo/latência desproporcionais. */
        const val MAX_MESSAGE_CHARS = 4000

        /** Orçamento aproximado de caracteres de histórico enviado por chamada. */
        private const val HISTORY_CHAR_BUDGET = 16000
        private const val HISTORY_MAX_TURNS = 40
    }

    val repository = Repository(application)
    val settings = Settings(application)

    private val claude = ClaudeClient { settings.apiKey }

    private val _isThinking = MutableStateFlow(false)
    val isThinking: StateFlow<Boolean> = _isThinking

    private val _autoSpeak = MutableStateFlow(settings.autoSpeak)
    val autoSpeak: StateFlow<Boolean> = _autoSpeak

    private val _isSpeaking = MutableStateFlow(false)
    val isSpeaking: StateFlow<Boolean> = _isSpeaking

    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private var currentJob: Job? = null

    init {
        Reminders.createChannel(application)
        repository.pruneReminders()
        tts = TextToSpeech(application) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale("pt", "BR")
                tts?.setOnUtteranceProgressListener(object : android.speech.tts.UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) { _isSpeaking.value = true }
                    override fun onDone(utteranceId: String?) { _isSpeaking.value = false }
                    override fun onError(utteranceId: String?) { _isSpeaking.value = false }
                })
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
        if (!newValue) stopSpeaking()
    }

    /**
     * Envia uma mensagem ao Claude.
     * @param displayText texto opcional mostrado na bolha do usuário no lugar de [text]
     *   (usado por atalhos como "resumo da semana", que enviam um prompt mais longo).
     */
    fun sendMessage(text: String, displayText: String? = null) {
        val trimmed = text.trim().take(MAX_MESSAGE_CHARS)
        if (trimmed.isEmpty() || _isThinking.value) return

        repository.addChatMessage("user", displayText ?: trimmed)

        if (settings.apiKey.isBlank()) {
            repository.addChatMessage(
                "assistant",
                "Antes de conversarmos, configure sua chave de API da Anthropic na aba Ajustes. Você cria uma em console.anthropic.com → API Keys."
            )
            return
        }

        _isThinking.value = true
        currentJob = viewModelScope.launch(Dispatchers.IO) {
            try {
                val system = ContextBuilder.build(
                    userName = settings.userName,
                    memories = repository.memories.value,
                    tasks = repository.tasks.value,
                    diary = repository.diary.value,
                    diaryStreak = repository.diaryStreakDays()
                )
                val reply = claude.chat(
                    system = system,
                    history = buildHistory(trimmed, displayText),
                    executeTool = ::executeTool,
                    isCancelled = { !isActive }
                )
                repository.addChatMessage("assistant", reply)
                if (_autoSpeak.value) speak(reply)
            } catch (e: Exception) {
                if (isActive) {
                    repository.addChatMessage("assistant", "⚠️ Não consegui responder: ${e.message ?: "erro desconhecido"}")
                }
            } finally {
                _isThinking.value = false
            }
        }
    }

    /** Envia um pedido de resumo da semana, mostrando um rótulo curto na bolha do usuário. */
    fun requestWeeklySummary() {
        sendMessage(
            text = "Faça um resumo carinhoso e perspicaz da minha última semana com base nas minhas tarefas, entradas de diário e memórias. Aponte um padrão que você notou e sugira algo gentil e concreto para os próximos dias. No máximo 6 frases.",
            displayText = "📊 Resumo da semana"
        )
    }

    /** Cancela a resposta em andamento (o usuário tocou em "parar"). */
    fun cancelThinking() {
        currentJob?.cancel()
        _isThinking.value = false
    }

    fun deleteChatMessage(id: String) = repository.deleteChatMessage(id)

    /** Histórico para a API: turnos de texto, começando com uma mensagem do usuário. */
    private fun buildHistory(pendingUserText: String, pendingDisplayText: String?): List<Pair<String, String>> {
        // A mensagem que acabou de ser adicionada ao repositório pode ter um rótulo de exibição
        // diferente do texto real enviado à IA (ex.: "📊 Resumo da semana"); usamos o texto real aqui.
        val all = repository.chat.value
            .filter { it.role == "user" || it.role == "assistant" }
            .takeLast(HISTORY_MAX_TURNS)
            .toMutableList()
        if (all.isNotEmpty() && pendingDisplayText != null && all.last().text == pendingDisplayText) {
            all[all.size - 1] = all.last().copy(text = pendingUserText)
        }

        val firstUser = all.indexOfFirst { it.role == "user" }
        if (firstUser < 0) return emptyList()
        val trimmedList = all.subList(firstUser, all.size)

        // Orçamento aproximado de caracteres: descarta turnos mais antigos se o histórico
        // crescer demais, mantendo sempre o primeiro turno como "user".
        var totalChars = trimmedList.sumOf { it.text.length }
        var start = 0
        while (totalChars > HISTORY_CHAR_BUDGET && start < trimmedList.size - 2) {
            totalChars -= trimmedList[start].text.length
            start++
        }
        // garante que ainda comece com "user" após o corte
        while (start < trimmedList.size && trimmedList[start].role != "user") start++

        return trimmedList.drop(start).map { it.role to it.text }
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

    private val isoFormatters = listOf(
        DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"),
        DateTimeFormatter.ISO_LOCAL_DATE_TIME
    )

    /** Interpreta datas ISO com tolerância a segundos extras e a horas/minutos sem zero à esquerda. */
    private fun parseLocalDateTime(raw: String): Long? {
        val trimmed = raw.trim()
        val candidates = if (trimmed.length > 16) listOf(trimmed, trimmed.take(16)) else listOf(trimmed)

        for (candidate in candidates) {
            for (formatter in isoFormatters) {
                try {
                    val local = LocalDateTime.parse(candidate, formatter)
                    return local.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                } catch (e: Exception) {
                    // tenta o próximo formato
                }
            }
        }

        // Último recurso: extrai os componentes manualmente, tolerando "2026-7-9T9:5"
        val match = Regex("""(\d{4})-(\d{1,2})-(\d{1,2})[T ](\d{1,2}):(\d{1,2})""").find(trimmed) ?: return null
        return try {
            val (y, mo, d, h, mi) = match.destructured
            val local = LocalDateTime.of(y.toInt(), mo.toInt(), d.toInt(), h.toInt(), mi.toInt())
            local.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
        } catch (e: Exception) {
            null
        }
    }

    fun speak(text: String) {
        if (!ttsReady) return
        val clean = stripForSpeech(text)
        if (clean.isNotEmpty()) {
            tts?.speak(clean, TextToSpeech.QUEUE_FLUSH, null, "reply")
        }
    }

    /**
     * Remove emojis e símbolos que soam mal no TTS, operando por code point
     * (evita corromper pares substitutos de emojis de 4 bytes como 🧠 ou 📊).
     */
    private fun stripForSpeech(text: String): String {
        val sb = StringBuilder(text.length)
        var i = 0
        while (i < text.length) {
            val codePoint = text.codePointAt(i)
            val charCount = Character.charCount(codePoint)
            val isSymbol = codePoint in 0x1F000..0x1FFFF || // emojis suplementares
                codePoint in 0x2190..0x2BFF || // setas e símbolos diversos
                codePoint in 0x2600..0x27BF || // símbolos/dingbats diversos
                codePoint == 0xFE0F || // seletor de variação (emoji vs texto)
                codePoint == 0x200D // zero-width joiner
            if (!isSymbol) sb.appendCodePoint(codePoint)
            i += charCount
        }
        return sb.toString().replace(Regex("[ \\t]{2,}"), " ").trim()
    }

    fun stopSpeaking() {
        tts?.stop()
        _isSpeaking.value = false
    }

    override fun onCleared() {
        currentJob?.cancel()
        tts?.shutdown()
        super.onCleared()
    }
}
