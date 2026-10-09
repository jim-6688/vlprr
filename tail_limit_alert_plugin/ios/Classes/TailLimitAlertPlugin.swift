import AVFoundation
import Flutter
import UserNotifications

/// TailLimit 强提醒插件（iOS）。
///
/// iOS 平台能力边界（诚实说明）：
/// - **Critical Alerts（关键警报）需要 Apple 特批 entitlement，本插件不使用**。
/// - 现实可用的最强手段 = 时间敏感通知（UNNotificationInterruptionLevel.timeSensitive，iOS 15+）
///   + 本地日历触发器（UNCalendarNotificationTrigger）。时间敏感通知可穿透专注模式、
///   在锁屏横幅常驻展示，但需用户在 设置 > 通知 > 时效性通知 中允许。
/// - 系统对待推送通知有 64 条上限，Dart 侧 Planner 已按优先级截断。
/// - TTS 使用 AVSpeechSynthesizer；应用被杀时无法后台朗读（系统限制），
///   此时依靠通知声音 + 时效性横幅完成"强提醒"。
public class TailLimitAlertPlugin: NSObject, FlutterPlugin, AVSpeechSynthesizerDelegate {

    private static let channelName = "com.taillimit.alert/channel"

    private let synthesizer = AVSpeechSynthesizer()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = TailLimitAlertPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public override init() {
        super.init()
        synthesizer.delegate = self
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCapabilities":
            result(capabilities())

        case "requestPermission":
            requestPermission(result: result)

        case "schedule":
            guard let payload = call.arguments as? [String: Any] else {
                result(["accepted": false, "reason": "empty payload"])
                return
            }
            schedule(payload: payload, result: result)

        case "cancel":
            if let args = call.arguments as? [String: Any],
               let id = args["id"] as? String {
                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(withIdentifiers: [id])
            }
            result(nil)

        case "showNow":
            if let payload = call.arguments as? [String: Any] {
                showNow(payload: payload)
            }
            result(nil)

        case "speakNow":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String {
                speak(text)
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - 能力探测

    private func capabilities() -> [String: Any] {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let isIOS15OrAbove = version.majorVersion >= 15
        return [
            "platformName": "ios",
            "exactAlarmSupported": true,          // UNCalendarNotificationTrigger 为系统精确调度
            "fullScreenIntentSupported": false,   // iOS 无全屏意图概念
            "ttsSupported": true,
            "bypassDndSupported": false,          // 专注模式由用户控制，无 API 旁路
            "timeSensitiveSupported": isIOS15OrAbove,
        ]
    }

    // MARK: - 授权

    private func requestPermission(result: @escaping FlutterResult) {
        let center = UNUserNotificationCenter.current()
        var options: UNAuthorizationOptions = [.alert, .sound, .badge]
        if #available(iOS 15.0, *) {
            // .criticalAlert 需 Apple 特批，此处不申请；
            // 时间敏感能力随 .alert 授权后由用户在系统设置中另行允许。
            options.insert(.provisional)
        }
        center.requestAuthorization(options: options) { granted, _ in
            DispatchQueue.main.async { result(granted) }
        }
    }

    // MARK: - 排程

    private func schedule(payload: [String: Any], result: @escaping FlutterResult) {
        guard let id = payload["id"] as? String else {
            result(["accepted": false, "reason": "missing id"])
            return
        }
        guard let fireAtMs = payload["fireAt"] as? NSNumber else {
            result(["accepted": false, "reason": "missing fireAt"])
            return
        }

        let fireDate = Date(timeIntervalSince1970: fireAtMs.doubleValue / 1000.0)
        guard fireDate > Date() else {
            result(["accepted": false, "reason": "fireAt in the past"])
            return
        }

        let content = UNMutableNotificationContent()
        content.title = payload["title"] as? String ?? "限行提醒"
        content.body = payload["body"] as? String ?? ""

        let isStrong = (payload["kind"] as? String) == "strong"
        // 注意：不使用 .defaultCriticalSound —— 它需要 Apple 特批的
        // Critical Alerts entitlement，未获批准时会导致通知静音甚至不展示。
        // 现实可用的最强手段是 .default 声音 + .timeSensitive 中断级别。
        content.sound = .default
        if #available(iOS 15.0, *) {
            content.interruptionLevel = isStrong ? .timeSensitive : .active
        }
        content.userInfo = payload
        content.categoryIdentifier = "TAILLIMIT_ALERT"

        // 使用日历触发器（不依赖 APNs，完全本地、离线可用）
        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    result(["accepted": false, "reason": error.localizedDescription])
                } else {
                    result(["accepted": true])
                }
            }
        }
    }

    // MARK: - 立即展示 / 播报

    private func showNow(payload: [String: Any]) {
        let content = UNMutableNotificationContent()
        content.title = payload["title"] as? String ?? "限行强提醒"
        content.body = payload["body"] as? String ?? ""
        // 同上：不使用 critical sound（需特批 entitlement）
        content.sound = .default
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: (payload["id"] as? String) ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)

        if let voice = payload["voiceText"] as? String {
            speak(voice)
        }
    }

    private func speak(_ text: String) {
        guard !text.isEmpty else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        synthesizer.speak(utterance)
    }
}
