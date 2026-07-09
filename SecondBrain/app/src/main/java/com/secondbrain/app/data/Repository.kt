package com.secondbrain.app.data

import android.content.Context
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Persistência simples em arquivos JSON no armazenamento interno do app.
 * Todo o estado é mantido em StateFlows para a UI reagir.
 */
class Repository(context: Context) {

    private val dir: File = context.filesDir

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
        return found
    }

    fun deleteTask(id: String): Boolean {
        val before = _tasks.value.size
        _tasks.value = _tasks.value.filterNot { it.id == id }
        save("tasks.json", _tasks.value.map { it.toJson() })
        return _tasks.value.size < before
    }

    // ---- Diário ----

    fun addDiaryEntry(text: String, mood: Int? = null): DiaryEntry {
        val entry = DiaryEntry(text = text, mood = mood)
        _diary.value = _diary.value + entry
        save("diary.json", _diary.value.map { it.toJson() })
        return entry
    }

    fun deleteDiaryEntry(id: String) {
        _diary.value = _diary.value.filterNot { it.id == id }
        save("diary.json", _diary.value.map { it.toJson() })
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

    @Synchronized
    private fun save(name: String, items: List<JSONObject>) {
        val arr = JSONArray()
        items.forEach { arr.put(it) }
        File(dir, name).writeText(arr.toString())
    }
}
