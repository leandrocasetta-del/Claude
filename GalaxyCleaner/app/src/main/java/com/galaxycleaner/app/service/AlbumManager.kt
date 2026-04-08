package com.galaxycleaner.app.service

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import com.galaxycleaner.app.model.Album
import com.galaxycleaner.app.model.MacroAction
import com.galaxycleaner.app.model.MacroPreset
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.util.UUID

class AlbumManager(private val context: Context) {

    companion object {
        private const val NOMEDIA_FILE = ".nomedia"
        private const val PREFS_NAME = "album_macros"
        private const val KEY_MACROS = "saved_macros"
    }

    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /** Loads all albums from MediaStore, marking hidden ones */
    suspend fun loadAlbums(): List<Album> = withContext(Dispatchers.IO) {
        val albumMap = mutableMapOf<String, Album>()

        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.BUCKET_ID,
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media.DATE_MODIFIED
        )

        val sortOrder = "${MediaStore.Images.Media.DATE_MODIFIED} DESC"

        context.contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            sortOrder
        )?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val bucketIdCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_ID)
            val nameCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
            val dataCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idCol)
                val bucketId = cursor.getString(bucketIdCol) ?: continue
                val name = cursor.getString(nameCol) ?: "Sem nome"
                val filePath = cursor.getString(dataCol) ?: continue
                val folderPath = File(filePath).parent ?: continue

                if (!albumMap.containsKey(bucketId)) {
                    val coverUri = Uri.withAppendedPath(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        id.toString()
                    ).toString()

                    val isHidden = File(folderPath, NOMEDIA_FILE).exists()

                    albumMap[bucketId] = Album(
                        id = bucketId.hashCode().toLong(),
                        name = name,
                        path = folderPath,
                        coverUri = coverUri,
                        photoCount = 0,
                        isHidden = isHidden
                    )
                }
            }
        }

        // Count photos per album
        val result = albumMap.values.map { album ->
            album.copy(photoCount = countPhotosInFolder(album.path))
        }

        // Also include hidden albums (they won't appear in MediaStore)
        val hiddenAlbums = findHiddenAlbums(albumMap.values.map { it.path })

        (result + hiddenAlbums).distinctBy { it.path }.sortedBy { it.name }
    }

    /** Toggle album visibility: add/remove .nomedia file */
    suspend fun toggleAlbumVisibility(album: Album): Boolean = withContext(Dispatchers.IO) {
        val folder = File(album.path)
        val nomediaFile = File(folder, NOMEDIA_FILE)

        if (album.isHidden) {
            // Show: remove .nomedia and trigger media scan
            val deleted = nomediaFile.delete()
            if (deleted) {
                triggerMediaScan(album.path)
            }
            deleted
        } else {
            // Hide: create .nomedia file
            if (!folder.exists()) return@withContext false
            val created = nomediaFile.createNewFile()
            if (created) {
                // Remove from MediaStore immediately
                removeFromMediaStore(album.path)
            }
            created
        }
    }

    /** Hide multiple albums at once (macro) */
    suspend fun hideAlbums(paths: List<String>): Int = withContext(Dispatchers.IO) {
        var count = 0
        paths.forEach { path ->
            val folder = File(path)
            val nomediaFile = File(folder, NOMEDIA_FILE)
            if (folder.exists() && !nomediaFile.exists()) {
                if (nomediaFile.createNewFile()) {
                    removeFromMediaStore(path)
                    count++
                }
            }
        }
        count
    }

    /** Show multiple albums at once (macro) */
    suspend fun showAlbums(paths: List<String>): Int = withContext(Dispatchers.IO) {
        var count = 0
        paths.forEach { path ->
            val nomediaFile = File(path, NOMEDIA_FILE)
            if (nomediaFile.exists() && nomediaFile.delete()) {
                triggerMediaScan(path)
                count++
            }
        }
        count
    }

    /** Save a macro preset to SharedPreferences */
    fun saveMacroPreset(name: String, albumPaths: List<String>, action: MacroAction): MacroPreset {
        val preset = MacroPreset(
            id = UUID.randomUUID().toString(),
            name = name,
            albumPaths = albumPaths,
            action = action
        )
        val existing = loadMacroPresets().toMutableList()
        existing.add(preset)
        saveMacros(existing)
        return preset
    }

    /** Delete a saved macro */
    fun deleteMacroPreset(id: String) {
        val existing = loadMacroPresets().filter { it.id != id }
        saveMacros(existing)
    }

    /** Load all saved macros */
    fun loadMacroPresets(): List<MacroPreset> {
        val json = prefs.getString(KEY_MACROS, null) ?: return emptyList()
        return parseMacrosJson(json)
    }

    /** Execute a saved macro */
    suspend fun executeMacro(preset: MacroPreset): Int = withContext(Dispatchers.IO) {
        when (preset.action) {
            MacroAction.HIDE -> hideAlbums(preset.albumPaths)
            MacroAction.SHOW -> showAlbums(preset.albumPaths)
        }
    }

    private fun countPhotosInFolder(folderPath: String): Int {
        val folder = File(folderPath)
        if (!folder.exists()) return 0
        return folder.listFiles()?.count { file ->
            file.isFile && isImageOrVideo(file.name)
        } ?: 0
    }

    private fun isImageOrVideo(name: String): Boolean {
        val lower = name.lowercase()
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") ||
                lower.endsWith(".png") || lower.endsWith(".gif") ||
                lower.endsWith(".webp") || lower.endsWith(".mp4") ||
                lower.endsWith(".mov") || lower.endsWith(".avi") ||
                lower.endsWith(".mkv") || lower.endsWith(".heic")
    }

    private fun findHiddenAlbums(knownPaths: List<String>): List<Album> {
        val hiddenAlbums = mutableListOf<Album>()
        val searchRoots = listOfNotNull(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM),
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        )

        searchRoots.forEach { root ->
            root.walkTopDown()
                .filter { it.isDirectory }
                .filter { dir -> File(dir, NOMEDIA_FILE).exists() }
                .filter { dir -> dir.absolutePath !in knownPaths }
                .forEach { dir ->
                    hiddenAlbums.add(
                        Album(
                            id = dir.absolutePath.hashCode().toLong(),
                            name = dir.name,
                            path = dir.absolutePath,
                            coverUri = null,
                            photoCount = countPhotosInFolder(dir.absolutePath),
                            isHidden = true
                        )
                    )
                }
        }

        return hiddenAlbums
    }

    private fun removeFromMediaStore(folderPath: String) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // On Android 10+, remove using selection
                val selection = "${MediaStore.Images.Media.DATA} LIKE ?"
                val selectionArgs = arrayOf("$folderPath/%")
                context.contentResolver.delete(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    selection,
                    selectionArgs
                )
                context.contentResolver.delete(
                    MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                    selection,
                    selectionArgs
                )
            }
        } catch (_: SecurityException) {
            // Permission not granted; the .nomedia file will hide on next scan
        }
    }

    private fun triggerMediaScan(folderPath: String) {
        try {
            // Insert a placeholder to trigger scan notification
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DATA, "$folderPath/")
            }
            context.contentResolver.insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                values
            )
        } catch (_: Exception) {
            // Scan will happen on next boot/gallery open
        }
    }

    private fun saveMacros(macros: List<MacroPreset>) {
        val json = buildString {
            append("[")
            macros.forEachIndexed { index, macro ->
                if (index > 0) append(",")
                append("{")
                append("\"id\":\"${macro.id}\",")
                append("\"name\":\"${macro.name}\",")
                append("\"action\":\"${macro.action.name}\",")
                append("\"paths\":[")
                macro.albumPaths.forEachIndexed { i, path ->
                    if (i > 0) append(",")
                    append("\"${path.replace("\"", "\\\"")}\"")
                }
                append("]}")
            }
            append("]")
        }
        prefs.edit().putString(KEY_MACROS, json).apply()
    }

    private fun parseMacrosJson(json: String): List<MacroPreset> {
        // Simple JSON parser for macro presets
        val result = mutableListOf<MacroPreset>()
        try {
            val items = json.trim().removePrefix("[").removeSuffix("]")
            if (items.isBlank()) return result

            // Split by top-level objects
            var depth = 0
            var start = 0
            val objects = mutableListOf<String>()
            items.forEachIndexed { i, ch ->
                when (ch) {
                    '{' -> { if (depth == 0) start = i; depth++ }
                    '}' -> {
                        depth--
                        if (depth == 0) objects.add(items.substring(start, i + 1))
                    }
                }
            }

            objects.forEach { obj ->
                val id = extractJsonString(obj, "id") ?: return@forEach
                val name = extractJsonString(obj, "name") ?: return@forEach
                val actionStr = extractJsonString(obj, "action") ?: return@forEach
                val action = try { MacroAction.valueOf(actionStr) } catch (_: Exception) { return@forEach }
                val paths = extractJsonArray(obj, "paths")
                result.add(MacroPreset(id, name, paths, action))
            }
        } catch (_: Exception) {}
        return result
    }

    private fun extractJsonString(json: String, key: String): String? {
        val pattern = "\"$key\":\"([^\"]*)\""
        val regex = Regex(pattern)
        return regex.find(json)?.groupValues?.get(1)
    }

    private fun extractJsonArray(json: String, key: String): List<String> {
        val result = mutableListOf<String>()
        val arrayPattern = "\"$key\":\\[([^\\]]*)]"
        val match = Regex(arrayPattern).find(json) ?: return result
        val content = match.groupValues[1]
        Regex("\"([^\"]*)\"").findAll(content).forEach {
            result.add(it.groupValues[1])
        }
        return result
    }
}
