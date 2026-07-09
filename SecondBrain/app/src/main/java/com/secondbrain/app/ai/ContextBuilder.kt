package com.secondbrain.app.ai

import com.secondbrain.app.data.DiaryEntry
import com.secondbrain.app.data.Memory
import com.secondbrain.app.data.Task
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Monta o prompt de sistema com todo o contexto da vida do usuário. */
object ContextBuilder {

    private val dateTimeFmt = SimpleDateFormat("EEEE, d 'de' MMMM 'de' yyyy, HH:mm", Locale("pt", "BR"))
    private val shortFmt = SimpleDateFormat("dd/MM HH:mm", Locale("pt", "BR"))
    private val isoFmt = SimpleDateFormat("yyyy-MM-dd'T'HH:mm", Locale.US)

    fun build(
        userName: String,
        memories: List<Memory>,
        tasks: List<Task>,
        diary: List<DiaryEntry>
    ): String {
        val now = Date()
        val sb = StringBuilder()

        sb.appendLine("Você é o \"segundo cérebro\" pessoal de ${userName.ifBlank { "seu usuário" }} — um assistente íntimo, atento e proativo que acompanha a vida dele em todos os detalhes.")
        sb.appendLine()
        sb.appendLine("Data e hora atual: ${dateTimeFmt.format(now)} (formato ISO: ${isoFmt.format(now)}).")
        sb.appendLine()

        sb.appendLine("## O que você já sabe sobre o usuário (memórias de longo prazo)")
        if (memories.isEmpty()) {
            sb.appendLine("(ainda nada — você está começando a conhecê-lo; seja curioso e salve o que aprender)")
        } else {
            memories.forEach { sb.appendLine("- [${it.id}] (${it.category}) ${it.content}") }
        }
        sb.appendLine()

        sb.appendLine("## Tarefas abertas")
        val open = tasks.filter { it.completedAt == null }
        if (open.isEmpty()) {
            sb.appendLine("(nenhuma)")
        } else {
            open.forEach {
                val due = it.due?.let { d -> " — prazo: $d" } ?: ""
                sb.appendLine("- [${it.id}] ${it.title}$due")
            }
        }
        sb.appendLine()

        sb.appendLine("## Últimas entradas do diário")
        val recent = diary.sortedByDescending { it.createdAt }.take(5)
        if (recent.isEmpty()) {
            sb.appendLine("(nenhuma ainda)")
        } else {
            recent.forEach {
                val mood = it.mood?.let { m -> " (humor $m/5)" } ?: ""
                sb.appendLine("- ${shortFmt.format(Date(it.createdAt))}$mood: ${it.text.take(200)}")
            }
        }
        sb.appendLine()

        sb.appendLine(
            """
            ## Como agir
            - Converse sempre em português brasileiro, num tom caloroso, direto e pessoal — como um amigo de confiança que conhece bem o usuário.
            - Use as ferramentas para AGIR, não apenas conversar: crie tarefas quando combinarem algo, registre no diário quando ele desabafar sobre o dia, agende lembretes quando houver horário envolvido.
            - Seja proativo em salvar memórias: sempre que o usuário revelar algo duradouro sobre si (preferências, pessoas, objetivos, rotina, saúde), use save_memory. Não anuncie que salvou; apenas salve.
            - Use as memórias e o histórico para perceber padrões e puxar assuntos relevantes (ex.: perguntar sobre algo que ele mencionou antes).
            - Respostas de voz devem funcionar bem faladas: para conversas normais, seja breve (2 a 4 frases). Só se estenda quando o usuário pedir análise ou ajuda detalhada.
            - Nunca invente fatos sobre o usuário que não estejam nas memórias ou na conversa.
            """.trimIndent()
        )

        return sb.toString()
    }
}
