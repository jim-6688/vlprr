package com.taillimit.alert

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * 告警触发广播接收器：闹钟到点 → 弹出通知（强提醒走全屏意图 + TTS 播报）。
 */
class AlertReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_FIRE_ALERT = "com.taillimit.alert.ACTION_FIRE_ALERT"
        const val EXTRA_PAYLOAD = "payload"
        const val EXTRA_ALERT_ID = "alert_id"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_FIRE_ALERT) return

        @Suppress("UNCHECKED_CAST")
        val payload = intent.getSerializableExtra(EXTRA_PAYLOAD) as? Map<String, Any?>
            ?: return
        val alertId = intent.getStringExtra(EXTRA_ALERT_ID) ?: return

        // 触发后清理持久化记录（一次性提醒）
        AlertStore.remove(context, alertId)
        AlertNotifier.show(context, payload, forceStrong = true)
    }
}

/**
 * 通知构建与展示。
 */
internal object AlertNotifier {

    fun show(context: Context, payload: Map<String, Any?>, forceStrong: Boolean) {
        val kind = payload["kind"] as? String ?: "preview"
        val isStrong = forceStrong || kind == "strong"

        val id = payload["id"] as? String ?: System.nanoTime().toString()

        val title = payload["title"] as? String ?: "限行提醒"
        val body = payload["body"] as? String ?: ""

        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

        val contentIntent = launchIntent?.let {
            PendingIntent.getActivity(
                context,
                id.hashCode(),
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        val builder = NotificationCompat.Builder(
            context,
            if (isStrong) TailLimitAlertPlugin.CHANNEL_STRONG
            else TailLimitAlertPlugin.CHANNEL_PREVIEW,
        )
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(
                if (isStrong) NotificationCompat.PRIORITY_MAX
                else NotificationCompat.PRIORITY_DEFAULT,
            )
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setWhen(System.currentTimeMillis())
            .setColor(Color.parseColor("#C9A96E"))
            .setContentIntent(contentIntent)

        if (isStrong) {
            builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            builder.setDefaults(NotificationCompat.DEFAULT_ALL or NotificationCompat.DEFAULT_VIBRATE)
            // 全屏意图：锁屏/息屏时直接点亮并展示全屏提醒
            builder.setFullScreenIntent(contentIntent, true)
        }

        runCatching {
            NotificationManagerCompat.from(context).notify(id.hashCode(), builder.build())
        }

        // 强提醒：语音播报（离线自足的 voiceText）
        if (isStrong) {
            val voice = payload["voiceText"] as? String
            if (!voice.isNullOrBlank()) {
                TtsSpeaker.speak(context, voice)
            }
        }
    }
}
