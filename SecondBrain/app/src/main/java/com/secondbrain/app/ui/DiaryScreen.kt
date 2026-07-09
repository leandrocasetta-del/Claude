package com.secondbrain.app.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.secondbrain.app.AppViewModel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

private val moods = listOf("😞", "😕", "😐", "🙂", "😄")

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DiaryScreen(viewModel: AppViewModel, modifier: Modifier = Modifier) {
    val entries by viewModel.repository.diary.collectAsState()
    var text by remember { mutableStateOf("") }
    var mood by remember { mutableIntStateOf(0) } // 0 = não selecionado
    val dateFmt = remember { SimpleDateFormat("EEE, dd/MM/yyyy HH:mm", Locale("pt", "BR")) }

    Column(modifier = modifier.fillMaxSize()) {
        TopAppBar(title = { Text("Diário") })

        Column(modifier = Modifier.padding(horizontal = 12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                moods.forEachIndexed { index, emoji ->
                    val selected = mood == index + 1
                    Text(
                        emoji,
                        style = if (selected) MaterialTheme.typography.headlineLarge
                        else MaterialTheme.typography.headlineSmall,
                        modifier = Modifier
                            .clickable { mood = if (selected) 0 else index + 1 }
                            .padding(4.dp)
                    )
                }
            }
            OutlinedTextField(
                value = text,
                onValueChange = { text = it },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("Como foi seu dia?") },
                minLines = 2,
                maxLines = 5
            )
            Button(
                onClick = {
                    viewModel.repository.addDiaryEntry(text.trim(), if (mood == 0) null else mood)
                    text = ""
                    mood = 0
                },
                enabled = text.isNotBlank(),
                modifier = Modifier.align(Alignment.End).padding(vertical = 8.dp)
            ) {
                Text("Registrar")
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(12.dp)
        ) {
            items(entries.sortedByDescending { it.createdAt }, key = { it.id }) { entry ->
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                dateFmt.format(Date(entry.createdAt)),
                                style = MaterialTheme.typography.labelMedium,
                                modifier = Modifier.weight(1f)
                            )
                            entry.mood?.let { m ->
                                Text(moods.getOrElse(m - 1) { "" })
                            }
                        }
                        Text(entry.text, style = MaterialTheme.typography.bodyLarge)
                    }
                }
            }
            if (entries.isEmpty()) {
                item {
                    Text(
                        "Nenhuma entrada ainda. Registre aqui ou simplesmente conte seu dia no chat.",
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(16.dp)
                    )
                }
            }
        }
    }
}
