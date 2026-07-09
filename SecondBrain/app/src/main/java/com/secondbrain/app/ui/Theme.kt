package com.secondbrain.app.ui

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

/**
 * Paleta própria — índigo/violeta, menta e âmbar (a mesma do ícone do app) —
 * em vez do roxo padrão do Material baseline, para o app ter identidade visual própria.
 * Em Android 12+ usamos cor dinâmica (Material You) quando disponível, que já é
 * pessoal por natureza; esta paleta é o fallback consistente em versões antigas.
 */
private val SecondBrainLight = lightColorScheme(
    primary = Color(0xFF4B5FD9),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFDEE1FF),
    onPrimaryContainer = Color(0xFF00105C),
    secondary = Color(0xFF3FA98A),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFC7F3E2),
    onSecondaryContainer = Color(0xFF002013),
    tertiary = Color(0xFFB8860B),
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFFFFE7B8),
    onTertiaryContainer = Color(0xFF2A1800),
    background = Color(0xFFFBFAFF),
    onBackground = Color(0xFF1B1B23),
    surface = Color(0xFFFBFAFF),
    onSurface = Color(0xFF1B1B23),
    surfaceVariant = Color(0xFFE7E6F5),
    onSurfaceVariant = Color(0xFF46464F)
)

private val SecondBrainDark = darkColorScheme(
    primary = Color(0xFFB7C0FF),
    onPrimary = Color(0xFF1B2367),
    primaryContainer = Color(0xFF33409E),
    onPrimaryContainer = Color(0xFFDEE1FF),
    secondary = Color(0xFF9EDCC4),
    onSecondary = Color(0xFF073829),
    secondaryContainer = Color(0xFF1F5140),
    onSecondaryContainer = Color(0xFFC7F3E2),
    tertiary = Color(0xFFF3CB79),
    onTertiary = Color(0xFF452B00),
    tertiaryContainer = Color(0xFF624000),
    onTertiaryContainer = Color(0xFFFFE7B8),
    background = Color(0xFF121218),
    onBackground = Color(0xFFE5E1E9),
    surface = Color(0xFF121218),
    onSurface = Color(0xFFE5E1E9),
    surfaceVariant = Color(0xFF2C2B3B),
    onSurfaceVariant = Color(0xFFC9C5D4)
)

@Composable
fun SecondBrainTheme(content: @Composable () -> Unit) {
    val dark = isSystemInDarkTheme()
    val context = LocalContext.current
    val colorScheme = when {
        Build.VERSION.SDK_INT >= 31 && dark -> dynamicDarkColorScheme(context)
        Build.VERSION.SDK_INT >= 31 -> dynamicLightColorScheme(context)
        dark -> SecondBrainDark
        else -> SecondBrainLight
    }
    MaterialTheme(colorScheme = colorScheme, content = content)
}
