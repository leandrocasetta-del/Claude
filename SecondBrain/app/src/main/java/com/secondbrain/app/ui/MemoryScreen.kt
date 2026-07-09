package com.secondbrain.app.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
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
    var selectedCategory by remember { mutableStateOf<String?>(null) }

    val categories = remember(memories) { memories.map { it.category }.distinct().sorted() }
    val visible = remember(memories, selectedCategory) {
        if (selectedCategory == null) memories else memories.filter { it.category == selectedCategory }
    }

    Column(modifier = modifier.fillMaxSize()) {
        TopAppBar(title = { Text("Memória — o que a IA sabe de você") })

        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = newMemory,
                onValueChange = { if (it.length <= 500) newMemory = it },
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

        if (categories.size > 1) {
            LazyRow(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 6.dp),
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                item {
                    FilterChip(
                        selected = selectedCategory == null,
                        onClick = { selectedCategory = null },
                        label = { Text("Todas") }
                    )
                }
                items(categories) { category ->
                    FilterChip(
                        selected = selectedCategory == category,
                        onClick = { selectedCategory = if (selectedCategory == category) null else category },
                        label = { Text(category) }
                    )
                }
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(12.dp)
        ) {
            items(visible.sortedByDescending { it.createdAt }, key = { it.id }) { memory ->
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
                            Icon(Icons.Filled.Delete, contentDescription = "Apagar memória")
                        }
                    }
                }
            }
            if (visible.isEmpty()) {
                item {
                    Text(
                        if (memories.isEmpty())
                            "Ainda vazio. Conforme você conversa, a IA vai guardando aqui o que aprende sobre você — e você pode revisar ou apagar qualquer item."
                        else "Nenhuma memória nessa categoria.",
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(16.dp)
                    )
                }
            }
        }
    }
}
