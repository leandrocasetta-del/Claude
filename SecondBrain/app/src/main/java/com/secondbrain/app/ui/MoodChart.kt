package com.secondbrain.app.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.unit.dp
import com.secondbrain.app.data.DiaryEntry
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

private val moodColors = listOf(
    Color(0xFFE57373), // 1 - muito mal
    Color(0xFFFFB74D), // 2
    Color(0xFFFFF176), // 3
    Color(0xFF81C784), // 4
    Color(0xFF4FC3F7)  // 5 - ótimo
)

/**
 * Mini gráfico de barras com o humor médio dos últimos 14 dias.
 * Dias sem registro aparecem como uma barra vazia/cinza.
 */
@Composable
fun MoodTrendChart(entries: List<DiaryEntry>, modifier: Modifier = Modifier) {
    val zone = ZoneId.systemDefault()
    val today = LocalDate.now(zone)
    val days = (13 downTo 0).map { today.minusDays(it.toLong()) }

    val moodByDay = entries
        .filter { it.mood != null }
        .groupBy { Instant.ofEpochMilli(it.createdAt).atZone(zone).toLocalDate() }
        .mapValues { (_, list) -> list.mapNotNull { it.mood }.average() }

    val hasAnyData = days.any { moodByDay.containsKey(it) }
    if (!hasAnyData) return

    val onSurfaceVariant = MaterialTheme.colorScheme.surfaceVariant

    Column(modifier = modifier.fillMaxWidth().padding(vertical = 8.dp)) {
        Text("Seu humor nos últimos 14 dias", style = MaterialTheme.typography.labelLarge)
        Canvas(
            modifier = Modifier
                .fillMaxWidth()
                .height(72.dp)
                .padding(top = 8.dp)
        ) {
            val barWidth = size.width / days.size
            val gap = barWidth * 0.25f
            days.forEachIndexed { index, day ->
                val avg = moodByDay[day]
                val x = index * barWidth + gap / 2
                val w = barWidth - gap
                if (avg != null) {
                    val fraction = (avg - 1) / 4f // 0..1
                    val barHeight = (size.height * (0.25f + 0.75f * fraction.coerceIn(0f, 1f)))
                    val colorIndex = Math.round(avg).toInt().coerceIn(1, 5) - 1
                    drawRoundRect(
                        color = moodColors[colorIndex],
                        topLeft = Offset(x, size.height - barHeight),
                        size = androidx.compose.ui.geometry.Size(w, barHeight),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(4f, 4f)
                    )
                } else {
                    drawLine(
                        color = onSurfaceVariant,
                        start = Offset(x, size.height - 4f),
                        end = Offset(x + w, size.height - 4f),
                        strokeWidth = 4f,
                        cap = StrokeCap.Round
                    )
                }
            }
        }
    }
}
