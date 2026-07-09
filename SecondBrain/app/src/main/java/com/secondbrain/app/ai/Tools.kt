package com.secondbrain.app.ai

import org.json.JSONArray
import org.json.JSONObject

/** Definições das ferramentas que o Claude pode usar para agir no app. */
object Tools {

    fun definitions(): JSONArray = JSONArray()
        .put(
            tool(
                "create_task",
                "Cria uma tarefa na lista de tarefas do usuário. Use quando o usuário pedir para anotar, lembrar de fazer algo, ou quando vocês combinarem uma ação concreta.",
                JSONObject()
                    .put("title", prop("string", "Título curto e claro da tarefa"))
                    .put("due", prop("string", "Prazo opcional no formato ISO local, ex.: 2026-07-10T09:00")),
                required = listOf("title")
            )
        )
        .put(
            tool(
                "complete_task",
                "Marca uma tarefa como concluída. Os ids das tarefas abertas estão no contexto do sistema.",
                JSONObject().put("id", prop("string", "Id da tarefa a concluir")),
                required = listOf("id")
            )
        )
        .put(
            tool(
                "delete_task",
                "Apaga uma tarefa da lista (use apenas se o usuário pedir explicitamente).",
                JSONObject().put("id", prop("string", "Id da tarefa a apagar")),
                required = listOf("id")
            )
        )
        .put(
            tool(
                "add_diary_entry",
                "Registra uma entrada no diário do usuário. Use quando o usuário contar como foi o dia, como está se sentindo, ou pedir para registrar algo pessoal.",
                JSONObject()
                    .put("text", prop("string", "Texto da entrada do diário, na voz do usuário"))
                    .put("mood", propInt("Humor de 1 (muito mal) a 5 (ótimo), se o usuário indicou como se sente")),
                required = listOf("text")
            )
        )
        .put(
            tool(
                "save_memory",
                "Salva um fato duradouro sobre o usuário na sua memória de longo prazo (preferências, pessoas importantes, objetivos, rotina, saúde). Use proativamente sempre que aprender algo relevante e duradouro. Não salve informações triviais ou passageiras.",
                JSONObject()
                    .put("content", prop("string", "O fato a lembrar, em uma frase objetiva"))
                    .put("category", prop("string", "Categoria: perfil, rotina, objetivos, pessoas, saude, trabalho ou geral")),
                required = listOf("content")
            )
        )
        .put(
            tool(
                "delete_memory",
                "Apaga uma memória que ficou desatualizada ou errada. Os ids estão no contexto do sistema.",
                JSONObject().put("id", prop("string", "Id da memória a apagar")),
                required = listOf("id")
            )
        )
        .put(
            tool(
                "set_reminder",
                "Agenda uma notificação de lembrete no celular do usuário para um horário específico.",
                JSONObject()
                    .put("message", prop("string", "Texto do lembrete que aparecerá na notificação"))
                    .put("datetime", prop("string", "Data e hora local no formato ISO, ex.: 2026-07-10T09:00")),
                required = listOf("message", "datetime")
            )
        )

    private fun tool(name: String, description: String, properties: JSONObject, required: List<String>): JSONObject {
        val requiredArr = JSONArray()
        required.forEach { requiredArr.put(it) }
        return JSONObject()
            .put("name", name)
            .put("description", description)
            .put(
                "input_schema",
                JSONObject()
                    .put("type", "object")
                    .put("properties", properties)
                    .put("required", requiredArr)
            )
    }

    private fun prop(type: String, description: String): JSONObject =
        JSONObject().put("type", type).put("description", description)

    private fun propInt(description: String): JSONObject =
        JSONObject().put("type", "integer").put("description", description)
}
