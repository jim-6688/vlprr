package com.taillimit.alert

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * TailLimit 强提醒插件（Android）。
 *
 * 强提醒能力：
 * - IMPORTANCE_HIGH 通知渠道（横幅 + 声音 + 震动）
 * - setFullScreenIntent 全屏意图（锁屏直接点亮，需 USE_FULL_SCREEN_INTENT）
 * - AlarmManager.setExactAndAllowWhileIdle 精确闹钟（免 Doze 延迟）
 * - TTS 语音播报
 * - 排程持久化到 SharedPreferences，配合 BootReceiver 开机重排（杀进程仍可触发）
 */
class TailLimitAlertPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.taillimit.alert/channel"
        const val PLUGIN_TAG = "TailLimitAlert"

        /** 通知渠道：强提醒（高优先级）。 */
        const val CHANNEL_STRONG = "taillimit_strong_alert"

        /** 通知渠道：普通预告。 */
        const val CHANNEL_PREVIEW = "taillimit_preview_alert"

        const val PREFS_NAME = "taillimit_alert_prefs"

        internal fun requestCodeOf(alertId: String): Int = alertId.hashCode()

        internal fun buildPendingIntent(
            context: Context,
            alertId: String,
            payload: Map<String, Any?>,
            flags: Int,
        ): PendingIntent {
            val intent = Intent(context, AlertReceiver::class.java).apply {
                action = AlertReceiver.ACTION_FIRE_ALERT
                putExtra(AlertReceiver.EXTRA_PAYLOAD, HashMap(payload))
                putExtra(AlertReceiver.EXTRA_ALERT_ID, alertId)
            }
            return PendingIntent.getBroadcast(
                context,
                requestCodeOf(alertId),
                intent,
                flags or PendingIntent.FLAG_UPDATE_CURRENT,
            )
        }
    }

    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        ensureChannels()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCapabilities" -> result.success(getCapabilities())
            "requestPermission" -> result.success(requestPermission())
            "schedule" -> result.success(schedule(call))
            "cancel" -> {
                cancel(call.argument<String>("id") ?: "")
                result.success(null)
            }
            "showNow" -> {
                showNow(call.arguments as? Map<String, Any?>)
                result.success(null)
            }
            "speakNow" -> {
                TtsSpeaker.speak(context, call.argument<String>("text") ?: "")
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // —— 能力探测 ——

    private fun getCapabilities(): Map<String, Any?> {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val exactSupported = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
        val notifManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val fullScreenSupported =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                notifManager.canUseFullScreenIntent()
            } else {
                true
            }
        val bypassDnd = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            notifManager.isNotificationPolicyAccessGranted
        } else {
            false
        }
        return mapOf(
            "platformName" to "android",
            "exactAlarmSupported" to exactSupported,
            "fullScreenIntentSupported" to fullScreenSupported,
            "ttsSupported" to true,
            "bypassDndSupported" to bypassDnd,
            "timeSensitiveSupported" to false,
        )
    }

    // —— 授权 ——

    private fun requestPermission(): Boolean {
        // 通知运行时权限（Android 13+）由 Flutter 侧通过 app 的 Activity 申请；
        // 此处处理需要跳系统设置页的两项：精确闹钟、勿扰旁路。
        var ok = NotificationManagerCompat.from(context).areNotificationsEnabled()

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            runCatching {
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
            }
            ok = false
        }
        return ok
    }

    // —— 排程 ——

    private fun schedule(call: MethodCall): Map<String, Any?> {
        val payload = call.arguments as? Map<String, Any?>
            ?: return mapOf("accepted" to false, "reason" to "empty payload")

        val alertId = payload["id"] as? String
            ?: return mapOf("accepted" to false, "reason" to "missing id")
        val fireAt = (payload["fireAt"] as? Number)?.toLong()
            ?: return mapOf("accepted" to false, "reason" to "missing fireAt")

        if (fireAt <= System.currentTimeMillis()) {
            return mapOf("accepted" to false, "reason" to "fireAt in the past")
        }

        // 1. 持久化（供开机重排使用）
        AlertStore.save(context, alertId, payload)

        // 2. 设置精确闹钟
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = buildPendingIntent(
            context,
            alertId,
            payload,
            PendingIntent.FLAG_UPDATE_CURRENT,
        )

        val accepted = runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                // 无精确闹钟权限：退化为非精确闹钟（仍可用，可能有分钟级延迟）
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, fireAt, pi)
            } else {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, fireAt, pi)
            }
        }.isSuccess

        return mapOf(
            "accepted" to accepted,
            "reason" to if (accepted) null else "alarm scheduling failed",
        )
    }

    private fun cancel(alertId: String) {
        AlertStore.remove(context, alertId)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = buildPendingIntent(context, alertId, emptyMap(), PendingIntent.FLAG_UPDATE_CURRENT)
        alarmManager.cancel(pi)
        NotificationManagerCompat.from(context).cancel(requestCodeOf(alertId))
    }

    // —— 立即展示 ——

    private fun showNow(payload: Map<String, Any?>?) {
        if (payload == null) return
        AlertNotifier.show(context, payload, forceStrong = true)
    }

    // —— 通知渠道 ——

    private fun ensureChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val strong = NotificationChannel(
            CHANNEL_STRONG,
            "限行强提醒",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "限号当日强提醒，全屏展示并语音播报"
            enableLights(true)
            enableVibration(true)
            setShowBadge(true)
            setBypassDnd(false)
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            setSound(
                android.provider.Settings.System.DEFAULT_NOTIFICATION_URI,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_EVENT)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
        }
        val preview = NotificationChannel(
            CHANNEL_PREVIEW,
            "限行预告",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "前一日限行预告提醒"
        }

        nm.createNotificationChannel(strong)
        nm.createNotificationChannel(preview)
    }
}
