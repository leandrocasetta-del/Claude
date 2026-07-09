package com.secondbrain.app.data

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys

/** Preferências do app; a chave de API fica em armazenamento criptografado. */
class Settings(context: Context) {

    private val prefs: SharedPreferences = try {
        val masterKey = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
        EncryptedSharedPreferences.create(
            "secure_prefs",
            masterKey,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    } catch (e: Exception) {
        // Fallback: se a keystore falhar (raro), usa prefs normais para não travar o app
        context.getSharedPreferences("plain_prefs", Context.MODE_PRIVATE)
    }

    var apiKey: String
        get() = prefs.getString("api_key", "") ?: ""
        set(value) { prefs.edit().putString("api_key", value.trim()).apply() }

    var userName: String
        get() = prefs.getString("user_name", "") ?: ""
        set(value) { prefs.edit().putString("user_name", value.trim()).apply() }

    var autoSpeak: Boolean
        get() = prefs.getBoolean("auto_speak", true)
        set(value) { prefs.edit().putBoolean("auto_speak", value).apply() }
}
