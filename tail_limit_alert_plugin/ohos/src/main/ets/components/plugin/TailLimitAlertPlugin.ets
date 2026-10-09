import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import common from '@ohos.app.ability.common';
import wantConstant from '@ohos.app.ability.wantConstant';
import {
  AlertCapabilities,
  AlertKind,
  AlertPayload,
  parsePayload,
} from '../alert/AlertModels';
import { AgentReminderHelper } from '../alert/AgentReminderHelper';
import { AlertStore } from '../alert/AlertStore';
import { TtsSpeaker } from '../utils/TtsSpeaker';

/**
 * TailLimit 强提醒插件 — 鸿蒙端实现。
 *
 * 通道名与 Dart 侧 AlertChannel 保持一致：`com.taillimit.alert/channel`
 *
 * 与 Android/iOS 实现保持同一套语义：
 * - getCapabilities  平台能力探测
 * - requestPermission 申请通知授权
 * - schedule         批量排程（幂等，按 id 覆盖）
 * - cancel           批量取消
 * - showNow          立即弹通知（含语音）
 * - speakNow         仅语音播报
 */
export class TailLimitAlertPlugin implements FlutterPlugin, MethodCallHandler {
  private static readonly CHANNEL_NAME: string = 'com.taillimit.alert/channel';

  private channel: MethodChannel | null = null;
  private context: common.UIAbilityContext | null = null;
  private store: AlertStore | null = null;

  getUniqueClassName(): string {
    return 'TailLimitAlertPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(
      binding.getBinaryMessenger(),
      TailLimitAlertPlugin.CHANNEL_NAME
    );
    this.channel.setMethodCallHandler(this);
    const ctx = binding.getApplicationContext() as common.UIAbilityContext;
    this.context = ctx;
    this.store = new AlertStore(ctx);
    // 预创建通知渠道，避免首次触发时延迟
    AgentReminderHelper.ensureNotificationSlot();
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel !== null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'getCapabilities':
          result.success(await this.capabilities());
          break;
        case 'requestPermission':
          result.success(await AgentReminderHelper.requestNotificationPermission());
          break;
        case 'schedule':
          await this.schedule(call);
          result.success(null);
          break;
        case 'cancel':
          await this.cancel(call);
          result.success(null);
          break;
        case 'showNow':
          await this.showNow(call);
          result.success(null);
          break;
        case 'speakNow':
          await this.speakNow(call);
          result.success(null);
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (e) {
      const err = e as Error;
      result.error('TAILLIMIT_OHOS_ERROR', err.message, null);
    }
  }

  /** 平台能力探测。 */
  private async capabilities(): Promise<AlertCapabilities> {
    const notifyEnabled = await AgentReminderHelper.isNotificationEnabled();
    const validCount = await AgentReminderHelper.countValid();

    return {
      platformName: 'HarmonyOS',
      // 系统代理提醒由系统托管，具备准点能力
      exactAlarmSupported: true,
      // 通过 maxScreenWantAgent 实现全屏拉起
      fullScreenIntentSupported: true,
      ttsSupported: true,
      // 通知渠道 bypassDnd 需要用户在系统设置中确认
      bypassDndSupported: true,
      // 鸿蒙无 iOS 的时效性通知概念，但高优先级渠道等效
      timeSensitiveSupported: false,
      agentReminderSupported: notifyEnabled && validCount >= 0,
    };
  }

  /**
   * 排程单条提醒。
   *
   * 契约与 Android/iOS/Dart 一致：`schedule` 只处理一条，
   * 入参为扁平化的 payload Map（非 { payload: {...} } 包装）。
   * 批量下发由 Dart 侧循环调用完成。
   */
  private async schedule(call: MethodCall): Promise<void> {
    const raw = call.arguments;
    if (raw === null || raw === undefined || typeof raw !== 'object') {
      return;
    }
    const ctx = this.context;
    if (ctx === null) {
      return;
    }

    const payload = parsePayload(raw as Record<string, Object>);

    // 已过期不排程（防止补发历史提醒）
    if (payload.fireAt <= Date.now()) {
      return;
    }

    await AgentReminderHelper.publishReminder(
      payload,
      ctx.applicationInfo.name,
      'EntryAbility'
    );

    // 更新本地事实源
    if (this.store !== null) {
      await this.store.upsert(payload);
    }
  }

  /** 取消单条提醒（契约与 Dart/Android 一致：入参 { id: String }）。 */
  private async cancel(call: MethodCall): Promise<void> {
    const id = call.argument('id');
    if (typeof id !== 'string' || id.length === 0) {
      return;
    }
    await AgentReminderHelper.cancelById(id);
    if (this.store !== null) {
      await this.store.remove([id]);
    }
  }

  /** 立即弹通知（可含语音）。入参为扁平化的 payload Map。 */
  private async showNow(call: MethodCall): Promise<void> {
    const raw = call.arguments;
    if (raw === null || raw === undefined || typeof raw !== 'object') {
      return;
    }
    const payload = parsePayload(raw as Record<string, Object>);
    await AgentReminderHelper.showNow(payload);

    if (payload.kind === AlertKind.STRONG && payload.voiceText.length > 0) {
      await TtsSpeaker.speak(payload.voiceText);
    }
  }

  /** 仅语音播报。 */
  private async speakNow(call: MethodCall): Promise<void> {
    const text = call.argument('text');
    if (typeof text === 'string' && text.length > 0) {
      await TtsSpeaker.speak(text);
    }
  }
}

export default TailLimitAlertPlugin;
