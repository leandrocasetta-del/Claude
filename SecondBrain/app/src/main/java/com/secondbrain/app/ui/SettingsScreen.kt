package com.secondbrain.app.ui

import android.net.Uri
import android.os.Build
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import com.secondbrain.app.AppViewModel
import com.secondbrain.app.ai.ClaudeClient
import com.secondbrain.app.notify.Reminders
import java.io.OutputStreamWriter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(viewModel: AppViewModel, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    var apiKey by remember { mutableStateOf(viewModel.settings.apiKey) }
    var userName by remember { mutableStateOf(viewModel.settings.userName) }
    val autoSpeak by viewModel.autoSpeak.collectAsState()
    var exactAlarmGranted by remember { mutableStateOf(Reminders.canScheduleExact(context)) }

    val exportLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.CreateDocument("text/plain")
    ) { uri: Uri? ->
        if (uri == null) return@rememberLauncherForActivityResult
        try {
            context.contentResolver.openOutputStream(uri)?.use { stream ->
                OutputStreamWriter(stream).use { it.write(viewModel.repository.exportAsText()) }
            }
            Toast.makeText(context, "Dados exportados!", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(context, "Não consegui exportar: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    Column(
        modifier = modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(bottom = 24.dp)
    ) {
        TopAppBar(title = { Text("Ajustes") })

        Column(modifier = Modifier.padding(horizontal = 16.dp)) {
            Text("Conexão com a IA", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = apiKey,
                onValueChange = { apiKey = it },
                modifier = Modifier.fillMaxWidth(),
                label = { Text("Chave de API da Anthropic") },
                placeholder = { Text("sk-ant-…") },
                visualTransformation = PasswordVisualTransformation(),
                singleLine = true
            )
            Text(
                "Crie a sua em console.anthropic.com → API Keys. A chave fica salva criptografada só neste aparelho. Modelo: ${ClaudeClient.MODEL}.",
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(top = 4.dp)
            )
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = userName,
                onValueChange = { userName = it },
                modifier = Modifier.fillMaxWidth(),
                label = { Text("Seu nome (como a IA deve te chamar)") },
                singleLine = true
            )
            Spacer(Modifier.height(8.dp))
            Button(onClick = {
                viewModel.settings.apiKey = apiKey
                viewModel.settings.userName = userName
                Toast.makeText(context, "Salvo!", Toast.LENGTH_SHORT).show()
            }) {
                Text("Salvar")
            }

            Spacer(Modifier.height(16.dp))
            HorizontalDivider()
            Spacer(Modifier.height(16.dp))

            Text("Voz", style = MaterialTheme.typography.titleMedium)
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)
            ) {
                Text("Ler respostas em voz alta", modifier = Modifier.weight(1f))
                Switch(checked = autoSpeak, onCheckedChange = { viewModel.toggleAutoSpeak() })
            }

            Spacer(Modifier.height(16.dp))
            HorizontalDivider()
            Spacer(Modifier.height(16.dp))

            Text("Lembretes", style = MaterialTheme.typography.titleMedium)
            if (Build.VERSION.SDK_INT >= 31 && !exactAlarmGranted) {
                Text(
                    "Sem a permissão de alarme exato, os lembretes podem chegar com alguns minutos de atraso.",
                    style = MaterialTheme.typography.bodySmall,
                    modifier = Modifier.padding(top = 4.dp)
                )
                Spacer(Modifier.height(4.dp))
                OutlinedButton(onClick = {
                    Reminders.openExactAlarmSettings(context)
                    exactAlarmGranted = Reminders.canScheduleExact(context)
                }) {
                    Text("Permitir alarmes exatos")
                }
            } else {
                Text(
                    "Lembretes vão disparar mesmo se o app for reiniciado ou o celular reiniciar.",
                    style = MaterialTheme.typography.bodySmall
                )
            }

            Spacer(Modifier.height(16.dp))
            HorizontalDivider()
            Spacer(Modifier.height(16.dp))

            Text("Dados", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(8.dp))
            OutlinedButton(onClick = {
                exportLauncher.launch("segundo-cerebro-backup.txt")
            }) {
                Text("Exportar meus dados")
            }
            Spacer(Modifier.height(8.dp))
            OutlinedButton(onClick = {
                viewModel.repository.clearChat()
                Toast.makeText(context, "Conversa apagada", Toast.LENGTH_SHORT).show()
            }) {
                Text("Limpar histórico de conversa")
            }
            Text(
                "Tarefas, diário e memórias ficam apenas neste aparelho. O contexto relevante é enviado à API da Anthropic a cada conversa para a IA te conhecer.",
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(top = 8.dp)
            )
        }
    }
}
