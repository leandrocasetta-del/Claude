package com.galaxycleaner.app.model

data class Album(
    val id: Long,
    val name: String,
    val path: String,
    val coverUri: String?,
    val photoCount: Int,
    var isHidden: Boolean
)
