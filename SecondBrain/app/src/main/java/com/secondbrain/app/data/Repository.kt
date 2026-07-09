package com.secondbrain.app.data

import android.content.Context
import com.secondbrain.app.widget.SecondBrainWidgetProvider
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.util.Date
import java.util.Locale

/**
 * Persistência simples em arquivos JSON no armazenamento interno do app.
 * Todo o estado é mantido em StateFlows para a UI reagir.
 */
class Repository(context: Context) {

    private val dir: File = context.filesDir
    private val appContext: Context = context.applicationContext

    private val _tasks = MutableStateFlow(load("tasks.json") { Task.fromJson(it) })
    val tasks: StateFlow<List<Task>> = _tasks

    private val _diary = MutableStateFlow(load("diary.json") { DiaryEntry.fromJson(it) })
    val diary: StateFlow<List<DiaryEntry>> = _diary

    private val _memories = MutableStateFlow(load("memories.json") { Memory.fromJson(it) })
    val memories: StateFlow<List<Memory>> = _memories

    private val _chat = MutableStateFlow(load("chat.json") { ChatMessage.fromJson(it) })
    val chat: StateFlow<List<ChatMessage>> = _chat

    private val _reminders = MutableStateFlow(load("reminders.json") { Reminder.fromJson(it) })
    val reminders: StateFlow<List<Reminder>> = _reminders

    // ---- Tarefas ----

    fun addTask(title: String, due: String? = null): Task {
        val task = Task(title = title, due = due)
        _tasks.value = _tasks.value + task
        save("tasks.json", _tasks.value.map { it.toJson() })
        notifyWidget()
        return task
    }

    fun completeTask(id: String): Task? {
        var found: Task? = null
        _tasks.value = _tasks.value.map {
            if (it.id == id && it.completedAt == null) {
                found = it.copy(completedAt = System.currentTimeMillis())
                found!!
            } else it
        }
        save("tasks.json", _tasks.value.map { it.toJson() })
        notifyWidget()
        return found
    }

    fun deleteTask(id: String): Boolean {
        val before = _tasks.value.size
        _tasks.value = _tasks.value.filterNot { it.id == id }
        save("tasks.json", _tasks.value.map { it.toJson() })
        notifyWidget()
        return _tasks.value.size < before
    }

    /** Remove todas as tarefas já concluídas (evita que a lista de concluídas cresça para sempre). */
    fun clearCompletedTasks() {
        _tasks.value = _tasks.value.filter { it.completedAt == null }
        save("tasks.json", _tasks.value.map { it.toJson() })
        notifyWidget()
    }

    // ---- Diário ----

    fun addDiaryEntry(text: String, mood: Int? = null): DiaryEntry {
        val entry = DiaryEntry(text = text, mood = mood)
        _diary.value = _diary.value + entry
        save("diary.json", _diary.value.map { it.toJson() })
        notifyWidget()
        return entry
    }

    fun deleteDiaryEntry(id: String) {
        _diary.value = _diary.value.filterNot { it.id == id }
        save("diary.json", _diary.value.map { it.toJson() })
        notifyWidget()
    }

    /** Dias consecutivos (incluindo hoje ou ontem) com pelo menos uma entrada no diário. */
    fun diaryStreakDays(): Int {
        val zone = ZoneId.systemDefault()
        val days = _diary.value
            .map { Instant.ofEpochMilli(it.createdAt).atZone(zone).toLocalDate() }
            .toHashSet()
        if (days.isEmpty()) return 0

        var cursor = LocalDate.now(zone)
        if (!days.contains(cursor)) {
            // Se não escreveu hoje ainda, o streak conta a partir de ontem
            // (não quebra o streak antes do fim do dia).
            cursor = cursor.minusDays(1)
            if (!days.contains(cursor)) return 0
        }
        var streak = 0
        while (days.contains(cursor)) {
            streak++
            cursor = cursor.minusDays(1)
        }
        return streak
    }

    // ---- Memórias ----

    fun addMemory(content: String, category: String = "geral"): Memory {
        val memory = Memory(content = content, category = category)
        _memories.value = _memories.value + memory
        save("memories.json", _memories.value.map { it.toJson() })
        return memory
    }

    fun deleteMemory(id: String): Boolean {
        val before = _memories.value.size
        _memories.value = _memories.value.filterNot { it.id == id }
        save("memories.json", _memories.value.map { it.toJson() })
        return _memories.value.size < before
    }

    // ---- Chat ----

    fun addChatMessage(role: String, text: String): ChatMessage {
        val msg = ChatMessage(role = role, text = text)
        _chat.value = _chat.value + msg
        save("chat.json", _chat.value.map { it.toJson() })
        return msg
    }

    fun deleteChatMessage(id: String) {
        _chat.value = _chat.value.filterNot { it.id == id }
        save("chat.json", _chat.value.map { it.toJson() })
    }

    fun clearChat() {
        _chat.value = emptyList()
        save("chat.json", emptyList())
    }

    // ---- Lembretes ----

    fun addReminder(message: String, triggerAt: Long): Reminder {
        val reminder = Reminder(message = message, triggerAt = triggerAt)
        _reminders.value = _reminders.value + reminder
        save("reminders.json", _reminders.value.map { it.toJson() })
        return reminder
    }

    fun pruneReminders() {
        val now = System.currentTimeMillis()
        _reminders.value = _reminders.value.filter { it.triggerAt > now }
        save("reminders.json", _reminders.value.map { it.toJson() })
    }

    // ---- Exportação (backup local legível) ----

    fun exportAsText(): String {
        val fmt = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale("pt", "BR"))
        val sb = StringBuilder()
        sb.appendLine("MEU SEGUNDO CÉREBRO — exportado em ${fmt.format(Date())}")
        sb.appendLine("=".repeat(50))

        sb.appendLine("\n## MEMÓRIAS")
        if (_memories.value.isEmpty()) sb.appendLine("(nenhuma)")
        _memories.value.forEach { sb.appendLine("- [${it.category}] ${it.content}") }

        sb.appendLine("\n## TAREFAS")
        _tasks.value.forEach {
            val status = if (it.completedAt != null) "[x]" else "[ ]"
            sb.appendLine("$status ${it.title}${it.due?.let { d -> " (prazo: $d)" } ?: ""}")
        }
        if (_tasks.value.isEmpty()) sb.appendLine("(nenhuma)")

        sb.appendLine("\n## DIÁRIO")
        _diary.value.sortedBy { it.createdAt }.forEach {
            val mood = it.mood?.let { m -> " (humor $m/5)" } ?: ""
            sb.appendLine("${fmt.format(Date(it.createdAt))}$mood: ${it.text}")
        }
        if (_diary.value.isEmpty()) sb.appendLine("(nenhuma)")

        return sb.toString()
    }

    // ---- Widget ----

    private fun notifyWidget() {
        try {
            SecondBrainWidgetProvider.requestUpdate(appContext)
        } catch (e: Exception) {
            // widget é opcional; nunca deve derrubar o app
        }
    }

    // ---- Arquivos ----

    private fun <T> load(name: String, parse: (JSONObject) -> T): List<T> {
        val file = File(dir, name)
        if (!file.exists()) return emptyList()
        return try {
            val arr = JSONArray(file.readText())
            (0 until arr.length()).map { parse(arr.getJSONObject(it)) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /** Grava em arquivo temporário e renomeia por cima do alvo, evitando corrupção se o processo morrer no meio da escrita. */
    @Synchronized
    private fun save(name: String, items: List<JSONObject>) {
        val arr = JSONArray()
        items.forEach { arr.put(it) }
        val target = File(dir, name)
        val tmp = File(dir, "$name.tmp")
        tmp.writeText(arr.toString())
        if (!tmp.renameTo(target)) {
            target.writeText(arr.toString())
            tmp.delete()
        }
    }
}
