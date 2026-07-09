package com.secondbrain.app.ui

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
import androidx.compose.material3.Card
import androidx.compose.material3.Checkbox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import com.secondbrain.app.AppViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TasksScreen(viewModel: AppViewModel, modifier: Modifier = Modifier) {
    val tasks by viewModel.repository.tasks.collectAsState()
    var newTask by remember { mutableStateOf("") }

    val open = tasks.filter { it.completedAt == null }
    val done = tasks.filter { it.completedAt != null }.sortedByDescending { it.completedAt }

    Column(modifier = modifier.fillMaxSize()) {
        TopAppBar(title = { Text("Tarefas") })

        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = newTask,
                onValueChange = { newTask = it },
                modifier = Modifier.weight(1f),
                placeholder = { Text("Nova tarefa…") },
                singleLine = true
            )
            IconButton(
                onClick = {
                    if (newTask.isNotBlank()) {
                        viewModel.repository.addTask(newTask.trim())
                        newTask = ""
                    }
                },
                enabled = newTask.isNotBlank()
            ) {
                Icon(Icons.Filled.Add, contentDescription = "Adicionar")
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
                            Icon(Icons.Filled.Delete, contentDescription = "Apagar")
                        }
                    }
                }
            }

            if (done.isNotEmpty()) {
                item {
                    Text(
                        "Concluídas",
                        style = MaterialTheme.typography.titleSmall,
                        modifier = Modifier.padding(top = 16.dp, bottom = 4.dp)
                    )
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
                            Icon(Icons.Filled.Delete, contentDescription = "Apagar")
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
