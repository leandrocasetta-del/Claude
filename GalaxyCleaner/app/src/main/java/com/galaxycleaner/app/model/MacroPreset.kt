package com.galaxycleaner.app.model

data class MacroPreset(
    val id: String,
    val name: String,
    val albumPaths: List<String>,
    val action: MacroAction
)

enum class MacroAction {
    HIDE, SHOW
}
