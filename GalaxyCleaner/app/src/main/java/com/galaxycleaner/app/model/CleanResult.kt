package com.galaxycleaner.app.model

data class CleanResult(
    val freedBytes: Long,
    val itemsRemoved: Int,
    val categories: List<CleanCategory>
)

data class CleanCategory(
    val name: String,
    val freedBytes: Long,
    val itemCount: Int,
    val iconRes: Int
)

data class StorageInfo(
    val totalBytes: Long,
    val usedBytes: Long,
    val freeBytes: Long,
    val cacheBytes: Long,
    val tempBytes: Long
)
