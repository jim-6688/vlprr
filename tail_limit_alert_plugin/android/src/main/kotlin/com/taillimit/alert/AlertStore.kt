package com.taillimit.alert

import android.content.Context
import android.content.SharedPreferences

/**
 * 排程持久化：SharedPreferences 保存待触发的提醒载荷。
 *
 * 键为 alertId，值为 JSON 序列化的载荷；开机后由 BootReceiver 读取并重排。
 */
internal object AlertStore {

    private const val KEY_PREFIX = "alert_"

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(TailLimitAlertPlugin.PREFS_NAME, Context.MODE_PRIVATE)

    fun save(context: Context, alertId: String, payload: Map<String, Any?>) {
        prefs(context).edit().putString(KEY_PREFIX + alertId, toJson(payload)).apply()
    }

    fun remove(context: Context, alertId: String) {
        prefs(context).edit().remove(KEY_PREFIX + alertId).apply()
    }

    /** 读取全部已保存载荷。 */
    fun loadAll(context: Context): List<Map<String, Any?>> {
        val out = mutableListOf<Map<String, Any?>>()
        for ((key, value) in prefs(context).all) {
            if (key.startsWith(KEY_PREFIX) && value is String) {
                runCatching { out.add(fromJson(value)) }
            }
        }
        return out
    }

    // —— 极简 JSON（避免引入第三方依赖，字段均为字符串/数字）——

    private fun toJson(map: Map<String, Any?>): String {
        val sb = StringBuilder("{")
        var first = true
        for ((k, v) in map) {
            if (!first) sb.append(",")
            first = false
            sb.append("\"").append(escape(k)).append("\":")
            when (v) {
                null -> sb.append("null")
                is Number, is Boolean -> sb.append(v.toString())
                else -> sb.append("\"").append(escape(v.toString())).append("\"")
            }
        }
        return sb.append("}").toString()
    }

    private fun fromJson(json: String): Map<String, Any?> {
        val out = mutableMapOf<String, Any?>()
        val body = json.trim().removePrefix("{").removeSuffix("}")
        // 按顶层逗号切分（值中不含逗号：正文可能含中文逗号"，"而非半角）
        var i = 0
        while (i < body.length) {
            val keyStart = body.indexOf('"', i)
            if (keyStart < 0) break
            val keyEnd = body.indexOf('"', keyStart + 1)
            if (keyEnd < 0) break
            val key = unescape(body.substring(keyStart + 1, keyEnd))
            val colon = body.indexOf(':', keyEnd)
            if (colon < 0) break
            var valueStart = colon + 1
            while (valueStart < body.length && body[valueStart] == ' ') valueStart++
            if (valueStart >= body.length) break

            if (body[valueStart] == '"') {
                val valueEnd = findStringEnd(body, valueStart + 1)
                out[key] = unescape(body.substring(valueStart + 1, valueEnd))
                i = valueEnd + 1
            } else {
                var valueEnd = body.indexOf(',', valueStart)
                if (valueEnd < 0) valueEnd = body.length
                val raw = body.substring(valueStart, valueEnd).trim()
                out[key] = when {
                    raw == "null" -> null
                    raw == "true" -> true
                    raw == "false" -> false
                    raw.contains('.') -> raw.toDoubleOrNull()
                    else -> raw.toLongOrNull() ?: raw
                }
                i = valueEnd + 1
            }
            // 跳过分隔逗号
            while (i < body.length && (body[i] == ',' || body[i] == ' ')) i++
        }
        return out
    }

    private fun findStringEnd(s: String, from: Int): Int {
        var idx = from
        while (idx < s.length) {
            if (s[idx] == '\\') {
                idx += 2
                continue
            }
            if (s[idx] == '"') return idx
            idx++
        }
        return s.length
    }

    private fun escape(s: String): String = s
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", "\\n")

    private fun unescape(s: String): String = s
        .replace("\\n", "\n")
        .replace("\\\"", "\"")
        .replace("\\\\", "\\")
}
