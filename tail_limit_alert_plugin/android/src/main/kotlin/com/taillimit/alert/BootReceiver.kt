package com.taillimit.alert

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * 开机重排：设备重启后 AlarmManager 中的闹钟全部丢失，
 * 需要从持久化存储读取未触发的提醒并重新设置精确闹钟。
 *
 * 这是"杀进程/重启后强提醒仍能触发"的关键保障。
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val isBoot = action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        if (!isBoot) return

        rescheduleAll(context)
    }

    private fun rescheduleAll(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val now = System.currentTimeMillis()

        for (payload in AlertStore.loadAll(context)) {
            val id = payload["id"] as? String ?: continue
            val fireAt = (payload["fireAt"] as? Number)?.toLong() ?: continue

            if (fireAt <= now) {
                // 已过期：清理，不再重排（App 下次启动会重算计划）
                AlertStore.remove(context, id)
                continue
            }

            val pi: PendingIntent = TailLimitAlertPlugin.buildPendingIntent(
                context,
                id,
                payload,
                PendingIntent.FLAG_UPDATE_CURRENT,
            )

            runCatching {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                    !alarmManager.canScheduleExactAlarms()
                ) {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, fireAt, pi)
                } else {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, fireAt, pi)
                }
            }
        }
    }
}
