import reminderAgentManager from '@ohos.reminderAgentManager';
import notificationManager from '@ohos.notificationManager';
import { AlertKind, AlertPayload } from './AlertModels';

/**
 * 系统代理提醒封装（鸿蒙强提醒的核心机制）。
 *
 * 设计要点：
 * - **代理提醒优于自建通知**：`reminderAgentManager` 由系统托管，
 *   应用被杀死或设备重启后依然能准时触发，这是与 Android 精确闹钟对等的官方方案。
 * - **强提醒 = 全屏弹窗 + 响铃 + 震动 + 语音**：鸿蒙通过 `wantAgent` 拉起源页 +
 *   `ringDuration`/`slotType`/`actionButton` 组合实现接近"全屏意图"的效果。
 * - 普通提醒（前一日预告）走 `notificationManager` 轻量通知，避免过度打扰。
 */
export class AgentReminderHelper {
  private static readonly REMINDER_SLOT_ID: number = 1001;

  /**
   * 创建通知渠道（强提醒走 SOCIAL_COMMUNICATION 高优先级）。
   * 需在应用启动时调用一次；重复调用幂等。
   */
  static async ensureNotificationSlot(): Promise<void> {
    try {
      const slot: notificationManager.NotificationSlot = {
        type: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        level: notificationManager.SlotLevel.LEVEL_HIGH,
        desc: '限号强提醒',
        badgeFlag: true,
        bypassDnd: true,
        vibrationEnabled: true,
        sound: '',
      };
      await notificationManager.addSlot(slot);
    } catch (e) {
      // 渠道已存在或系统限制时忽略
    }
  }

  /**
   * 申请通知授权。
   *
   * @returns 是否已获得授权
   */
  static async requestNotificationPermission(): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled();
      if (enabled) {
        return true;
      }
      await notificationManager.requestEnableNotification();
      // 弹窗异步，返回当前状态；用户确认后下次进入生效
      return await notificationManager.isNotificationEnabled();
    } catch (e) {
      return false;
    }
  }

  /** 通知授权状态。 */
  static async isNotificationEnabled(): Promise<boolean> {
    try {
      return await notificationManager.isNotificationEnabled();
    } catch (e) {
      return false;
    }
  }

  /**
   * 发布一条系统代理提醒。
   *
   * @param payload 提醒载荷
   * @param bundleName 应用包名（用于 wantAgent 拉起）
   * @param abilityName 目标 Ability 名（通常为 EntryAbility）
   */
  static async publishReminder(
    payload: AlertPayload,
    bundleName: string,
    abilityName: string
  ): Promise<void> {
    const isStrong = payload.kind === AlertKind.STRONG;

    // wantAgent：点击通知后拉起应用首页
    const wantAgent: reminderAgentManager.WantAgent = {
      pkgName: bundleName,
      abilityName: abilityName,
      parameters: {
        tailLimitReminderId: payload.id,
        tailLimitCityId: payload.cityId,
        tailLimitDateIso: payload.dateIso,
      },
    };

    // 最大铃响时长：强提醒 30 秒，普通提醒 5 秒
    const maxRingDuration = isStrong ? 30 : 5;

    // 按钮：强提醒提供"知道了"快捷操作
    const buttons: Array<reminderAgentManager.ActionButton> = [];
    if (isStrong) {
      buttons.push({
        title: '知道了',
        type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE,
      });
    }

    const reminder: reminderAgentManager.ReminderRequestAlarm = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
      // 单次触发：fireAt 为绝对毫秒时间戳
      hour: new Date(payload.fireAt).getHours(),
      minute: new Date(payload.fireAt).getMinutes(),
      daysOfWeek: [],
      // 标题与内容
      title: payload.title,
      content: payload.body,
      expiredContent: `${payload.plateText} 今日限行，请注意`,
      snoozeContent: isStrong ? `${payload.plateText} 限行提醒` : undefined,
      notificationId: AgentReminderHelper.hashId(payload.id),
      slotType: isStrong
        ? reminderAgentManager.SlotType.SOCIAL_COMMUNICATION
        : reminderAgentManager.SlotType.CONTENT_INFORMATION,
      // 强提醒：响铃 + 震动 + 全屏意图
      actionButton: buttons.length > 0 ? buttons : undefined,
      wantAgent: wantAgent,
      maxScreenWantAgent: isStrong ? wantAgent : undefined,
      ringDuration: maxRingDuration,
      snoozeTimes: isStrong ? 1 : 0,
      // 重复间隔（分钟）：仅强提醒允许稍后提醒
      timeInterval: isStrong ? 5 : 0,
      tapDismissed: true,
      autoDeleted: true,
      // 语音播报文本（鸿蒙部分版本支持 content 朗读）
      customRingUri: undefined,
    };

    // 若与已有提醒 ID 冲突，先取消再发布（幂等）
    await AgentReminderHelper.cancelById(payload.id);

    try {
      await reminderAgentManager.publishReminder(reminder);
    } catch (e) {
      // 部分设备不支持 maxScreenWantAgent，降级重试
      const fallback: reminderAgentManager.ReminderRequestAlarm = {
        ...reminder,
        maxScreenWantAgent: undefined,
      };
      await reminderAgentManager.publishReminder(fallback);
    }
  }

  /**
   * 取消单个提醒。
   *
   * @returns 是否成功取消
   */
  static async cancelById(reminderId: string): Promise<boolean> {
    try {
      const reminderIdNum = AgentReminderHelper.hashId(reminderId);
      const list = await reminderAgentManager.getValidReminders();
      const target = list.find((r) => r.reminderId === reminderIdNum);
      if (target === undefined) {
        return false;
      }
      await reminderAgentManager.cancelReminder(target.reminderId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /**
   * 取消全部提醒（用于配置重置或卸载前清理）。
   */
  static async cancelAll(): Promise<void> {
    try {
      const list = await reminderAgentManager.getValidReminders();
      for (const r of list) {
        await reminderAgentManager.cancelReminder(r.reminderId);
      }
    } catch (e) {
      // 忽略
    }
  }

  /** 当前有效提醒数量。 */
  static async countValid(): Promise<number> {
    try {
      const list = await reminderAgentManager.getValidReminders();
      return list.length;
    } catch (e) {
      return 0;
    }
  }

  /**
   * 立即弹出一条通知（应用内演示 / 无法排程时的兜底）。
   */
  static async showNow(payload: AlertPayload): Promise<void> {
    try {
      await AgentReminderHelper.ensureNotificationSlot();
      const request: notificationManager.NotificationRequest = {
        id: AgentReminderHelper.hashId(payload.id),
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: payload.title,
            text: payload.body,
            additionalText: payload.timeWindowText,
          },
        },
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        // 强提醒：横幅 + 响铃 + 震动
        tapDismissed: true,
        isUnremovable: false,
        isAlertOnce: false,
      };
      await notificationManager.publish(request);
    } catch (e) {
      // 通知发布失败不抛出，避免影响主流程
    }
  }

  /**
   * 字符串 ID 转稳定数值 ID（鸿蒙 reminderId 为 number）。
   *
   * 使用 FNV-1a 32 位哈希，保证同一字符串跨进程得到相同结果。
   */
  static hashId(input: string): number {
    let hash = 0x811c9dc5;
    for (let i = 0; i < input.length; i++) {
      hash ^= input.charCodeAt(i);
      // FNV 质数 16777619
      hash = (hash * 16777619) >>> 0;
    }
    // 收敛到 32 位有符号正整数范围
    return hash % 0x7fffffff;
  }
}
