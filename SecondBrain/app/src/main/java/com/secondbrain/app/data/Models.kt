package com.secondbrain.app.data

import org.json.JSONObject
import java.util.UUID

data class Task(
    val id: String = UUID.randomUUID().toString().take(8),
    val title: String,
    val due: String? = null,
    val createdAt: Long = System.currentTimeMillis(),
    val completedAt: Long? = null
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("title", title)
        .put("due", due ?: JSONObject.NULL)
        .put("createdAt", createdAt)
        .put("completedAt", completedAt ?: JSONObject.NULL)

    companion object {
        fun fromJson(o: JSONObject) = Task(
            id = o.getString("id"),
            title = o.getString("title"),
            due = if (o.isNull("due")) null else o.getString("due"),
            createdAt = o.getLong("createdAt"),
            completedAt = if (o.isNull("completedAt")) null else o.getLong("completedAt")
        )
    }
}

data class DiaryEntry(
    val id: String = UUID.randomUUID().toString().take(8),
    val text: String,
    val mood: Int? = null,
    val createdAt: Long = System.currentTimeMillis()
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("text", text)
        .put("mood", mood ?: JSONObject.NULL)
        .put("createdAt", createdAt)

    companion object {
        fun fromJson(o: JSONObject) = DiaryEntry(
            id = o.getString("id"),
            text = o.getString("text"),
            mood = if (o.isNull("mood")) null else o.getInt("mood"),
            createdAt = o.getLong("createdAt")
        )
    }
}

data class Memory(
    val id: String = UUID.randomUUID().toString().take(8),
    val content: String,
    val category: String = "geral",
    val createdAt: Long = System.currentTimeMillis()
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("content", content)
        .put("category", category)
        .put("createdAt", createdAt)

    companion object {
        fun fromJson(o: JSONObject) = Memory(
            id = o.getString("id"),
            content = o.getString("content"),
            category = o.optString("category", "geral"),
            createdAt = o.getLong("createdAt")
        )
    }
}

data class ChatMessage(
    val id: String = UUID.randomUUID().toString().take(8),
    val role: String,
    val text: String,
    val createdAt: Long = System.currentTimeMillis()
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("role", role)
        .put("text", text)
        .put("createdAt", createdAt)

    companion object {
        fun fromJson(o: JSONObject) = ChatMessage(
            id = o.getString("id"),
            role = o.getString("role"),
            text = o.getString("text"),
            createdAt = o.getLong("createdAt")
        )
    }
}

data class Reminder(
    val id: String = UUID.randomUUID().toString().take(8),
    val message: String,
    val triggerAt: Long
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("message", message)
        .put("triggerAt", triggerAt)

    companion object {
        fun fromJson(o: JSONObject) = Reminder(
            id = o.getString("id"),
            message = o.getString("message"),
            triggerAt = o.getLong("triggerAt")
        )
    }
}
