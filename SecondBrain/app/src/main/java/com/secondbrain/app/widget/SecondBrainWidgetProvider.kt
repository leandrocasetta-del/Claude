package com.secondbrain.app.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.secondbrain.app.MainActivity
import com.secondbrain.app.R
import com.secondbrain.app.data.Repository

/**
 * Widget de tela inicial: mostra tarefas pendentes e a sequência do diário.
 * Somente leitura — todo o trabalho de gerar dados vem do [Repository].
 */
class SecondBrainWidgetProvider : AppWidgetProvider() {

    companion object {
        /** Pede atualização imediata (chamado pelo Repository após mudanças relevantes). */
        fun requestUpdate(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, SecondBrainWidgetProvider::class.java))
            if (ids.isNotEmpty()) {
                val intent = Intent(context, SecondBrainWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(intent)
            }
        }

        private fun buildViews(context: Context): RemoteViews {
            val repository = Repository(context)
            val openTasks = repository.tasks.value.count { it.completedAt == null }
            val streak = repository.diaryStreakDays()

            val views = RemoteViews(context.packageName, R.layout.widget_secondbrain)
            views.setTextViewText(
                R.id.widget_tasks,
                when {
                    openTasks == 0 -> "Nenhuma tarefa pendente 🎉"
                    openTasks == 1 -> "1 tarefa pendente"
                    else -> "$openTasks tarefas pendentes"
                }
            )
            views.setTextViewText(
                R.id.widget_streak,
                if (streak > 0) "🔥 $streak dia${if (streak > 1) "s" else ""} seguidos de diário"
                else "Registre seu dia hoje"
            )

            val openApp = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, openApp)
            return views
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val views = buildViews(context)
        appWidgetIds.forEach { id -> appWidgetManager.updateAppWidget(id, views) }
    }
}
