package com.secondbrain.app.ui

import android.content.ActivityNotFoundException
import android.content.Intent
import android.speech.RecognizerIntent
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.secondbrain.app.AppViewModel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun ChatScreen(viewModel: AppViewModel, modifier: Modifier = Modifier) {
    val messages by viewModel.repository.chat.collectAsState()
    val tasks by viewModel.repository.tasks.collectAsState()
    val diary by viewModel.repository.diary.collectAsState()
    val isThinking by viewModel.isThinking.collectAsState()
    val autoSpeak by viewModel.autoSpeak.collectAsState()
    val isSpeaking by viewModel.isSpeaking.collectAsState()
    var input by remember { mutableStateOf("") }
    var messageToDelete by remember { mutableStateOf<String?>(null) }
    val listState = rememberLazyListState()
    val context = LocalContext.current
    val timeFmt = remember { SimpleDateFormat("HH:mm", Locale("pt", "BR")) }

    val speechLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val spoken = result.data
            ?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            ?.firstOrNull()
        if (!spoken.isNullOrBlank()) viewModel.sendMessage(spoken)
    }

    LaunchedEffect(messages.size, isThinking) {
        val lastIndex = if (isThinking) messages.size else messages.size - 1
        if (lastIndex >= 0) listState.animateScrollToItem(lastIndex)
    }

    val streak = remember(diary) { viewModel.repository.diaryStreakDays() }
    val todayIso = remember { SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date()) }
    val tasksDueToday = remember(tasks) { tasks.count { it.completedAt == null && it.due?.startsWith(todayIso) == true } }
    val showHeader = streak > 0 || tasksDueToday > 0

    messageToDelete?.let { id ->
        AlertDialog(
            onDismissRequest = { messageToDelete = null },
            title = { Text("Apagar mensagem?") },
            text = { Text("Essa mensagem some só do histórico visível — ela não é reenviada à IA.") },
            confirmButton = {
                TextButton(onClick = {
                    viewModel.deleteChatMessage(id)
                    messageToDelete = null
                }) { Text("Apagar") }
            },
            dismissButton = {
                TextButton(onClick = { messageToDelete = null }) { Text("Cancelar") }
            }
        )
    }

    Column(modifier = modifier.fillMaxSize().imePadding()) {
        TopAppBar(
            title = { Text("Segundo Cérebro 🧠") },
            actions = {
                IconButton(
                    onClick = {
                        if (isSpeaking) viewModel.stopSpeaking() else viewModel.toggleAutoSpeak()
                    },
                    modifier = Modifier.semantics {
                        contentDescription = if (autoSpeak) "Desativar leitura em voz alta" else "Ativar leitura em voz alta"
                    }
                ) {
                    Text(if (autoSpeak) "🔊" else "🔇", style = MaterialTheme.typography.titleLarge)
                }
            }
        )

        if (showHeader) {
            TodayHeader(
                streak = streak,
                tasksDueToday = tasksDueToday,
                enabled = !isThinking,
                onRequestSummary = { viewModel.requestWeeklySummary() }
            )
        }

        BoxWithConstraints(modifier = Modifier.weight(1f).fillMaxWidth()) {
            val bubbleMaxWidth = maxWidth * 0.78f
            LazyColumn(
                state = listState,
                modifier = Modifier.fillMaxSize(),
                contentPadding = androidx.compose.foundation.layout.PaddingValues(12.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(messages, key = { it.id }) { msg ->
                    val isUser = msg.role == "user"
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalAlignment = if (isUser) Alignment.End else Alignment.Start
                    ) {
                        Box(
                            modifier = Modifier
                                .widthIn(max = bubbleMaxWidth)
                                .combinedClickable(
                                    onClick = {},
                                    onLongClick = { messageToDelete = msg.id }
                                )
                                .background(
                                    color = if (isUser) MaterialTheme.colorScheme.primaryContainer
                                    else MaterialTheme.colorScheme.surfaceVariant,
                                    shape = RoundedCornerShape(
                                        topStart = 16.dp,
                                        topEnd = 16.dp,
                                        bottomStart = if (isUser) 16.dp else 4.dp,
                                        bottomEnd = if (isUser) 4.dp else 16.dp
                                    )
                                )
                                .padding(horizontal = 14.dp, vertical = 10.dp)
                        ) {
                            Text(msg.text, style = MaterialTheme.typography.bodyLarge)
                        }
                        Text(
                            timeFmt.format(Date(msg.createdAt)),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }
                if (isThinking) {
                    item {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            CircularProgressIndicator(modifier = Modifier.padding(8.dp).widthIn(max = 20.dp))
                            Text("pensando…", fontWeight = FontWeight.Light, modifier = Modifier.weight(1f))
                            TextButton(onClick = { viewModel.cancelThinking() }) {
                                Icon(Icons.Filled.Close, contentDescription = null, modifier = Modifier.size(16.dp))
                                Text(" Parar")
                            }
                        }
                    }
                }
            }
        }

        Row(
            modifier = Modifier.fillMaxWidth().padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = input,
                onValueChange = { if (it.length <= AppViewModel.MAX_MESSAGE_CHARS) input = it },
                modifier = Modifier.weight(1f),
                placeholder = { Text("Fale comigo…") },
                maxLines = 4,
                shape = RoundedCornerShape(24.dp)
            )
            IconButton(
                onClick = {
                    val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE, "pt-BR")
                        putExtra(RecognizerIntent.EXTRA_PROMPT, "Fale com seu segundo cérebro…")
                    }
                    try {
                        speechLauncher.launch(intent)
                    } catch (e: ActivityNotFoundException) {
                        Toast.makeText(context, "Reconhecimento de voz indisponível neste aparelho", Toast.LENGTH_SHORT).show()
                    }
                },
                modifier = Modifier.semantics { contentDescription = "Falar por voz" }
            ) {
                Text("🎙️", style = MaterialTheme.typography.titleLarge)
            }
            IconButton(
                onClick = {
                    viewModel.sendMessage(input)
                    input = ""
                },
                enabled = input.isNotBlank() && !isThinking,
                modifier = Modifier.semantics { contentDescription = "Enviar mensagem" }
            ) {
                Icon(Icons.AutoMirrored.Filled.Send, contentDescription = null)
            }
        }
    }
}

@Composable
private fun TodayHeader(
    streak: Int,
    tasksDueToday: Int,
    enabled: Boolean,
    onRequestSummary: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 6.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Column(modifier = Modifier.weight(1f)) {
                if (streak > 0) {
                    Text(
                        "🔥 $streak dia${if (streak > 1) "s" else ""} seguidos no diário",
                        style = MaterialTheme.typography.labelLarge
                    )
                }
                if (tasksDueToday > 0) {
                    Text(
                        "$tasksDueToday tarefa${if (tasksDueToday > 1) "s" else ""} com prazo hoje",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
            AssistChip(
                onClick = onRequestSummary,
                enabled = enabled,
                label = { Text("📊 Resumo") }
            )
        }
    }
}
