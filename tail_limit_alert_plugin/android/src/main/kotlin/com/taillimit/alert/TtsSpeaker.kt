package com.taillimit.alert

import android.content.Context
import android.speech.tts.TextToSpeech
import java.util.Locale

/**
 * TTS 语音播报（中文）。
 *
 * 强提醒触发时朗读离线自足的 voiceText，例如
 * "提醒，您绑定的车辆京A12345，今日限行，限行尾号4和9，限行时间7:00-20:00，请合理安排出行。"
 */
internal object TtsSpeaker {

    @Volatile
    private var tts: TextToSpeech? = null

    @Volatile
    private var ready = false

    @Volatile
    private var pendingText: String? = null

    fun speak(context: Context, text: String) {
        if (text.isBlank()) return

        val current = tts
        if (current != null && ready) {
            current.speak(text, TextToSpeech.QUEUE_FLUSH, null, "taillimit_${System.currentTimeMillis()}")
            return
        }
        pendingText = text

        if (current == null) {
            synchronized(this) {
                if (tts == null) {
                    val engine = TextToSpeech(context.applicationContext) { status ->
                        ready = status == TextToSpeech.SUCCESS
                        if (ready) {
                            tts?.language = Locale.SIMPLIFIED_CHINESE
                            tts?.setSpeechRate(0.95f)
                            pendingText?.let { t ->
                                tts?.speak(t, TextToSpeech.QUEUE_FLUSH, null, "taillimit_init")
                            }
                            pendingText = null
                        }
                    }
                    tts = engine
                }
            }
        }
    }

    fun shutdown() {
        tts?.stop()
        tts?.shutdown()
        tts = null
        ready = false
    }
}
