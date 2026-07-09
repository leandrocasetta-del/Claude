package com.secondbrain.app.notify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.secondbrain.app.data.Repository

/**
 * Alarmes do AlarmManager são cancelados quando o aparelho reinicia.
 * Este receiver reagenda todos os lembretes futuros assim que o sistema termina de iniciar,
 * corrigindo o caso em que um lembrete "desaparece" depois de reiniciar o celular.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        Reminders.createChannel(context)
        val repository = Repository(context)
        val now = System.currentTimeMillis()
        repository.reminders.value
            .filter { it.triggerAt > now }
            .forEach { reminder -> Reminders.schedule(context, reminder.id, reminder.message, reminder.triggerAt) }
    }
}
