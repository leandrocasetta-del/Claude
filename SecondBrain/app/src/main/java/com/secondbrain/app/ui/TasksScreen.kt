package com.secondbrain.app.ui

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Card
import androidx.compose.material3.Checkbox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import com.secondbrain.app.AppViewModel
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Calendar

private const val MAX_TASK_CHARS = 200
private val dueFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")
private val dueDisplayFormatter = DateTimeFormatter.ofPattern("dd/MM HH:mm")

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TasksScreen(viewModel: AppViewModel, modifier: Modifier = Modifier) {
    val tasks by viewModel.repository.tasks.collectAsState()
    var newTask by remember { mutableStateOf("") }
    var dueDateTime by remember { mutableStateOf<LocalDateTime?>(null) }
    val context = LocalContext.current

    val open = tasks.filter { it.completedAt == null }
    val done = tasks.filter { it.completedAt != null }.sortedByDescending { it.completedAt }

    fun pickDueDateTime() {
        val now = Calendar.getInstance()
        DatePickerDialog(
            context,
            { _, year, month, day ->
                TimePickerDialog(
                    context,
                    { _, hour, minute -> dueDateTime = LocalDateTime.of(year, month + 1, day, hour, minute) },
                    now.get(Calendar.HOUR_OF_DAY),
                    now.get(Calendar.MINUTE),
                    true
                ).show()
            },
            now.get(Calendar.YEAR),
            now.get(Calendar.MONTH),
            now.get(Calendar.DAY_OF_MONTH)
        ).show()
    }

    fun addTask() {
        if (newTask.isBlank()) return
        viewModel.repository.addTask(newTask.trim(), dueDateTime?.format(dueFormatter))
        newTask = ""
        dueDateTime = null
    }

    Column(modifier = modifier.fillMaxSize()) {
        TopAppBar(title = { Text("Tarefas") })

        Column(modifier = Modifier.padding(horizontal = 12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                OutlinedTextField(
                    value = newTask,
                    onValueChange = { if (it.length <= MAX_TASK_CHARS) newTask = it },
                    modifier = Modifier.weight(1f),
                    placeholder = { Text("Nova tarefa…") },
                    singleLine = true
                )
                IconButton(onClick = ::addTask, enabled = newTask.isNotBlank()) {
                    Icon(Icons.Filled.Add, contentDescription = "Adicionar tarefa")
                }
            }
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(bottom = 6.dp)) {
                AssistChip(
                    onClick = { pickDueDateTime() },
                    leadingIcon = { Icon(Icons.Filled.DateRange, contentDescription = null) },
                    label = {
                        Text(dueDateTime?.format(dueDisplayFormatter) ?: "Definir prazo (opcional)")
                    }
                )
                if (dueDateTime != null) {
                    TextButton(onClick = { dueDateTime = null }) { Text("Remover") }
                }
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(12.dp)
        ) {
            items(open, key = { it.id }) { task ->
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Checkbox(
                            checked = false,
                            onCheckedChange = { viewModel.repository.completeTask(task.id) }
                        )
                        Column(modifier = Modifier.weight(1f)) {
                            Text(task.title, style = MaterialTheme.typography.bodyLarge)
                            task.due?.let {
                                Text("Prazo: $it", style = MaterialTheme.typography.bodySmall)
                            }
                        }
                        IconButton(onClick = { viewModel.repository.deleteTask(task.id) }) {
                            Icon(Icons.Filled.Delete, contentDescription = "Apagar tarefa")
                        }
                    }
                }
            }

            if (done.isNotEmpty()) {
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 16.dp, bottom = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            "Concluídas",
                            style = MaterialTheme.typography.titleSmall,
                            modifier = Modifier.weight(1f)
                        )
                        TextButton(onClick = { viewModel.repository.clearCompletedTasks() }) {
                            Text("Limpar")
                        }
                    }
                }
                items(done, key = { it.id }) { task ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp)
                    ) {
                        Checkbox(checked = true, onCheckedChange = null, enabled = false)
                        Text(
                            task.title,
                            style = MaterialTheme.typography.bodyMedium,
                            textDecoration = TextDecoration.LineThrough,
                            modifier = Modifier.weight(1f)
                        )
                        IconButton(onClick = { viewModel.repository.deleteTask(task.id) }) {
                            Icon(Icons.Filled.Delete, contentDescription = "Apagar tarefa concluída")
                        }
                    }
                }
            }

            if (tasks.isEmpty()) {
                item {
                    Text(
                        "Nenhuma tarefa ainda. Peça no chat: \"anota aí: comprar leite amanhã\".",
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(16.dp)
                    )
                }
            }
        }
    }
}
