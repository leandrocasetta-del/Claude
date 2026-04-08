package com.galaxycleaner.app.service

import android.content.Context
import android.os.Environment
import android.os.StatFs
import com.galaxycleaner.app.R
import com.galaxycleaner.app.model.CleanCategory
import com.galaxycleaner.app.model.CleanResult
import com.galaxycleaner.app.model.StorageInfo
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

class CleanerManager(private val context: Context) {

    suspend fun getStorageInfo(): StorageInfo = withContext(Dispatchers.IO) {
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalBytes = stat.totalBytes
        val freeBytes = stat.availableBytes
        val usedBytes = totalBytes - freeBytes

        val cacheBytes = calculateCacheSize()
        val tempBytes = calculateTempSize()

        StorageInfo(
            totalBytes = totalBytes,
            usedBytes = usedBytes,
            freeBytes = freeBytes,
            cacheBytes = cacheBytes,
            tempBytes = tempBytes
        )
    }

    suspend fun performClean(
        clearCache: Boolean = true,
        clearTemp: Boolean = true,
        clearThumbnails: Boolean = true,
        clearEmptyFolders: Boolean = true
    ): CleanResult = withContext(Dispatchers.IO) {
        val categories = mutableListOf<CleanCategory>()
        var totalFreed = 0L
        var totalItems = 0

        if (clearCache) {
            val result = cleanCache()
            totalFreed += result.first
            totalItems += result.second
            categories.add(
                CleanCategory(
                    name = "Cache de Aplicativos",
                    freedBytes = result.first,
                    itemCount = result.second,
                    iconRes = R.drawable.ic_cache
                )
            )
        }

        if (clearTemp) {
            val result = cleanTempFiles()
            totalFreed += result.first
            totalItems += result.second
            categories.add(
                CleanCategory(
                    name = "Arquivos Temporarios",
                    freedBytes = result.first,
                    itemCount = result.second,
                    iconRes = R.drawable.ic_temp
                )
            )
        }

        if (clearThumbnails) {
            val result = cleanThumbnails()
            totalFreed += result.first
            totalItems += result.second
            categories.add(
                CleanCategory(
                    name = "Miniaturas",
                    freedBytes = result.first,
                    itemCount = result.second,
                    iconRes = R.drawable.ic_thumbnail
                )
            )
        }

        if (clearEmptyFolders) {
            val result = cleanEmptyFolders()
            totalFreed += result.first
            totalItems += result.second
            categories.add(
                CleanCategory(
                    name = "Pastas Vazias",
                    freedBytes = result.first,
                    itemCount = result.second,
                    iconRes = R.drawable.ic_folder
                )
            )
        }

        CleanResult(
            freedBytes = totalFreed,
            itemsRemoved = totalItems,
            categories = categories
        )
    }

    private fun cleanCache(): Pair<Long, Int> {
        var freed = 0L
        var count = 0

        // Internal app cache
        val internalCache = context.cacheDir
        freed += deleteContents(internalCache)
        count += countFiles(internalCache)

        // External app cache
        context.externalCacheDir?.let { externalCache ->
            freed += deleteContents(externalCache)
            count += countFiles(externalCache)
        }

        return Pair(freed, count)
    }

    private fun cleanTempFiles(): Pair<Long, Int> {
        var freed = 0L
        var count = 0

        val tempExtensions = listOf(".tmp", ".temp", ".bak", ".log", ".dmp")
        val searchDirs = listOfNotNull(
            context.filesDir,
            context.getExternalFilesDir(null),
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        )

        searchDirs.forEach { dir ->
            if (dir.exists()) {
                dir.walkTopDown()
                    .filter { it.isFile && tempExtensions.any { ext -> it.name.endsWith(ext, true) } }
                    .forEach { file ->
                        val size = file.length()
                        if (file.delete()) {
                            freed += size
                            count++
                        }
                    }
            }
        }

        return Pair(freed, count)
    }

    private fun cleanThumbnails(): Pair<Long, Int> {
        var freed = 0L
        var count = 0

        // Android thumbnail cache locations
        val thumbnailDirs = listOf(
            File(Environment.getExternalStorageDirectory(), "DCIM/.thumbnails"),
            File(Environment.getExternalStorageDirectory(), "Pictures/.thumbnails"),
            File(Environment.getExternalStorageDirectory(), ".thumbnails")
        )

        thumbnailDirs.forEach { dir ->
            if (dir.exists()) {
                freed += deleteContents(dir)
                count += countFiles(dir)
            }
        }

        return Pair(freed, count)
    }

    private fun cleanEmptyFolders(): Pair<Long, Int> {
        var count = 0

        val baseDir = context.getExternalFilesDir(null) ?: return Pair(0L, 0)

        baseDir.walkBottomUp()
            .filter { it.isDirectory && it != baseDir }
            .filter { dir -> dir.listFiles()?.isEmpty() == true }
            .forEach { dir ->
                if (dir.delete()) count++
            }

        return Pair(0L, count)
    }

    private fun deleteContents(dir: File): Long {
        if (!dir.exists()) return 0L
        var freed = 0L
        dir.listFiles()?.forEach { file ->
            freed += if (file.isDirectory) {
                deleteContents(file)
                file.delete()
                0L
            } else {
                val size = file.length()
                if (file.delete()) size else 0L
            }
        }
        return freed
    }

    private fun countFiles(dir: File): Int {
        if (!dir.exists()) return 0
        return dir.walkTopDown().filter { it.isFile }.count()
    }

    private fun calculateCacheSize(): Long {
        var size = 0L
        size += getDirSize(context.cacheDir)
        context.externalCacheDir?.let { size += getDirSize(it) }
        return size
    }

    private fun calculateTempSize(): Long {
        var size = 0L
        val tempExtensions = listOf(".tmp", ".temp", ".bak", ".log")
        val searchDirs = listOfNotNull(
            context.filesDir,
            context.getExternalFilesDir(null)
        )
        searchDirs.forEach { dir ->
            if (dir.exists()) {
                dir.walkTopDown()
                    .filter { it.isFile && tempExtensions.any { ext -> it.name.endsWith(ext, true) } }
                    .forEach { size += it.length() }
            }
        }
        return size
    }

    private fun getDirSize(dir: File): Long {
        if (!dir.exists()) return 0L
        return dir.walkTopDown().filter { it.isFile }.sumOf { it.length() }
    }

    fun formatBytes(bytes: Long): String {
        return when {
            bytes < 1024 -> "$bytes B"
            bytes < 1024 * 1024 -> "${bytes / 1024} KB"
            bytes < 1024 * 1024 * 1024 -> "${bytes / (1024 * 1024)} MB"
            else -> String.format("%.1f GB", bytes / (1024.0 * 1024.0 * 1024.0))
        }
    }
}
