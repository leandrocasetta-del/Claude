package com.galaxycleaner.app.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.galaxycleaner.app.MainActivity
import com.galaxycleaner.app.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class CleanerForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "cleaner_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_CLEAN = "com.galaxycleaner.ACTION_CLEAN"
        const val ACTION_STOP = "com.galaxycleaner.ACTION_STOP"
    }

    private val job = SupervisorJob()
    private val scope = CoroutineScope(Dispatchers.IO + job)
    private lateinit var cleanerManager: CleanerManager

    override fun onCreate() {
        super.onCreate()
        cleanerManager = CleanerManager(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CLEAN -> startCleaning()
            ACTION_STOP -> stopSelf()
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        job.cancel()
    }

    private fun startCleaning() {
        val notification = buildNotification("Limpando memoria...", "Aguarde enquanto o Galaxy Cleaner remove arquivos desnecessarios")
        startForeground(NOTIFICATION_ID, notification)

        scope.launch {
            val result = cleanerManager.performClean()
            val freed = cleanerManager.formatBytes(result.freedBytes)

            updateNotification(
                "Limpeza concluida!",
                "Liberados $freed - ${result.itemsRemoved} itens removidos"
            )
            stopForeground(STOP_FOREGROUND_DETACH)
            stopSelf()
        }
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Galaxy Cleaner",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Notificacoes de limpeza de memoria"
            setShowBadge(false)
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(title: String, content: String) =
        NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_clean)
            .setContentTitle(title)
            .setContentText(content)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setContentIntent(
                PendingIntent.getActivity(
                    this, 0,
                    Intent(this, MainActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
            .build()

    private fun updateNotification(title: String, content: String) {
        val notification = buildNotification(title, content)
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, notification)
    }
}
