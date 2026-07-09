package com.secondbrain.app.ai

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * Cliente da Messages API da Anthropic (raw HTTP via OkHttp).
 * Implementa o loop agêntico: enquanto o modelo pedir ferramentas
 * (stop_reason == "tool_use"), executa-as localmente e devolve os resultados.
 */
class ClaudeClient(private val apiKeyProvider: () -> String) {

    companion object {
        const val MODEL = "claude-opus-4-8"
        private const val API_URL = "https://api.anthropic.com/v1/messages"
        private const val MAX_TOOL_ROUNDS = 12
        private const val MAX_RETRIES = 2
        private val RETRY_DELAYS_MS = longArrayOf(800, 2400)
    }

    private val http = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(300, TimeUnit.SECONDS)
        .callTimeout(300, TimeUnit.SECONDS)
        .build()

    private val jsonMedia = "application/json; charset=utf-8".toMediaType()

    /** Erro amigável e classificado, para a UI decidir como reagir. */
    class ApiException(message: String, val retryable: Boolean = false) : IOException(message)

    /**
     * Envia a conversa e resolve chamadas de ferramenta até obter a resposta final.
     *
     * @param system prompt de sistema com o contexto da vida do usuário
     * @param history pares (role, texto) da conversa, começando com "user"
     * @param executeTool executa uma ferramenta localmente e retorna o resultado como texto
     * @param isCancelled checagem cooperativa de cancelamento entre rodadas de ferramentas
     */
    fun chat(
        system: String,
        history: List<Pair<String, String>>,
        executeTool: (name: String, input: JSONObject) -> String,
        isCancelled: () -> Boolean = { false }
    ): String {
        val messages = JSONArray()
        history.forEach { (role, text) ->
            messages.put(JSONObject().put("role", role).put("content", text))
        }

        var rounds = 0
        while (true) {
            if (isCancelled()) throw IOException("Cancelado")
            val response = send(system, messages)
            val content = response.getJSONArray("content")
            val stopReason = response.optString("stop_reason")

            when (stopReason) {
                "tool_use" -> {
                    if (++rounds > MAX_TOOL_ROUNDS) {
                        return "Executei várias ações mas atingi o limite de passos. Me pergunte de novo se faltou algo."
                    }
                    // Devolve o conteúdo do assistente inteiro (incluindo blocos de thinking)
                    messages.put(JSONObject().put("role", "assistant").put("content", content))
                    val results = JSONArray()
                    for (i in 0 until content.length()) {
                        val block = content.getJSONObject(i)
                        if (block.getString("type") == "tool_use") {
                            val result = try {
                                executeTool(block.getString("name"), block.getJSONObject("input"))
                            } catch (e: Exception) {
                                "Erro ao executar: ${e.message}"
                            }
                            results.put(
                                JSONObject()
                                    .put("type", "tool_result")
                                    .put("tool_use_id", block.getString("id"))
                                    .put("content", result)
                            )
                        }
                    }
                    messages.put(JSONObject().put("role", "user").put("content", results))
                }

                "pause_turn" -> {
                    messages.put(JSONObject().put("role", "assistant").put("content", content))
                }

                "refusal" -> return "Desculpe, não posso ajudar com esse pedido específico."

                else -> {
                    val texts = StringBuilder()
                    for (i in 0 until content.length()) {
                        val block = content.getJSONObject(i)
                        if (block.getString("type") == "text") {
                            if (texts.isNotEmpty()) texts.append("\n\n")
                            texts.append(block.getString("text"))
                        }
                    }
                    return texts.toString().ifBlank { "(sem resposta)" }
                }
            }
        }
    }

    private fun send(system: String, messages: JSONArray): JSONObject {
        val apiKey = apiKeyProvider()
        if (apiKey.isBlank()) {
            throw ApiException("Chave de API não configurada. Vá em Ajustes e cole sua chave.")
        }

        // System como bloco de texto com cache_control: turnos consecutivos do mesmo
        // loop de ferramentas (e conversas onde o contexto não mudou) reaproveitam o
        // prefixo cacheado, reduzindo custo e latência.
        val systemBlocks = JSONArray().put(
            JSONObject()
                .put("type", "text")
                .put("text", system)
                .put("cache_control", JSONObject().put("type", "ephemeral"))
        )

        val body = JSONObject()
            .put("model", MODEL)
            .put("max_tokens", 8192)
            .put("system", systemBlocks)
            .put("thinking", JSONObject().put("type", "adaptive"))
            .put("messages", messages)
            .put("tools", Tools.definitions())

        val request = Request.Builder()
            .url(API_URL)
            .header("x-api-key", apiKey)
            .header("anthropic-version", "2023-06-01")
            .post(body.toString().toRequestBody(jsonMedia))
            .build()

        var lastError: Exception? = null
        for (attempt in 0..MAX_RETRIES) {
            try {
                http.newCall(request).execute().use { resp ->
                    val text = resp.body?.string() ?: ""
                    if (resp.isSuccessful) return JSONObject(text)

                    val apiMessage = try {
                        JSONObject(text).getJSONObject("error").getString("message")
                    } catch (e: Exception) {
                        null
                    }

                    when (resp.code) {
                        401, 403 -> throw ApiException(
                            "Chave de API inválida ou sem permissão. Confira em Ajustes."
                        )
                        429 -> {
                            if (attempt < MAX_RETRIES) {
                                Thread.sleep(RETRY_DELAYS_MS[attempt])
                                return@use
                            }
                            throw ApiException(
                                "Muitas mensagens em pouco tempo. Espere alguns segundos e tente de novo.",
                                retryable = true
                            )
                        }
                        in 500..599 -> {
                            if (attempt < MAX_RETRIES) {
                                Thread.sleep(RETRY_DELAYS_MS[attempt])
                                return@use
                            }
                            throw ApiException(
                                "O servidor da Anthropic está instável agora. Tente de novo em instantes.",
                                retryable = true
                            )
                        }
                        else -> throw ApiException(apiMessage ?: "Erro inesperado (HTTP ${resp.code}).")
                    }
                }
                // Se chegou aqui é porque um retry foi agendado (return@use acima); continua o loop.
            } catch (e: ApiException) {
                throw e
            } catch (e: IOException) {
                lastError = e
                if (attempt < MAX_RETRIES) {
                    Thread.sleep(RETRY_DELAYS_MS[attempt])
                } else {
                    throw ApiException("Sem conexão com a internet. Verifique sua rede.", retryable = true)
                }
            }
        }
        throw lastError ?: ApiException("Falha desconhecida ao contatar a IA.")
    }
}
