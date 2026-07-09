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
import androidx.compose.ui.unit.dp
import com.secondbrain.app.AppViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MemoryScreen(viewModel: AppViewModel, modifier: Modifier = Modifier) {
    val memories by viewModel.repository.memories.collectAsState()
    var newMemory by remember { mutableStateOf("") }

    Column(modifier = modifier.fillMaxSize()) {
        TopAppBar(title = { Text("Memória — o que a IA sabe de você") })

        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = newMemory,
                onValueChange = { newMemory = it },
                modifier = Modifier.weight(1f),
                placeholder = { Text("Ex.: Treino segunda, quarta e sexta") },
                singleLine = true
            )
            IconButton(
                onClick = {
                    if (newMemory.isNotBlank()) {
                        viewModel.repository.addMemory(newMemory.trim())
                        newMemory = ""
                    }
                },
                enabled = newMemory.isNotBlank()
            ) {
                Icon(Icons.Filled.Add, contentDescription = "Adicionar")
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(12.dp)
        ) {
            items(memories.sortedByDescending { it.createdAt }, key = { it.id }) { memory ->
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(start = 12.dp)
                    ) {
                        Column(modifier = Modifier.weight(1f).padding(vertical = 10.dp)) {
                            Text(memory.content, style = MaterialTheme.typography.bodyLarge)
                            Text(memory.category, style = MaterialTheme.typography.labelSmall)
                        }
                        IconButton(onClick = { viewModel.repository.deleteMemory(memory.id) }) {
                            Icon(Icons.Filled.Delete, contentDescription = "Apagar")
                        }
                    }
                }
            }
            if (memories.isEmpty()) {
                item {
                    Text(
                        "Ainda vazio. Conforme você conversa, a IA vai guardando aqui o que aprende sobre você — e você pode revisar ou apagar qualquer item.",
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(16.dp)
                    )
                }
            }
        }
    }
}
