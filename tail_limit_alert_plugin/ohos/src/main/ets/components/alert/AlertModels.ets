/**
 * TailLimit 鸿蒙端提醒数据模型。
 *
 * 与 Dart 侧 lib/src/alert_models.dart 的 AlertPayload 一一对应，
 * 字段名保持一致以避免映射出错。
 */

/** 提醒类型。 */
export enum AlertKind {
  PREVIEW = 'preview',
  STRONG = 'strong',
}

/** 排程载荷（离线自足：通知内容全部内联，触发时不依赖网络与应用进程）。 */
export interface AlertPayload {
  /** 确定性提醒 ID（由 Dart 侧生成，幂等键）。 */
  id: string;
  kind: string;
  /** 触发时刻的毫秒时间戳。 */
  fireAt: number;
  title: string;
  body: string;
  /** 语音播报文本（为空则不播报）。 */
  voiceText: string;
  cityId: string;
  cityName: string;
  dateIso: string;
  plateText: string;
  tailsText: string;
  timeWindowText: string;
  areaText: string;
}

/** 平台能力探测结果。 */
export interface AlertCapabilities {
  platformName: string;
  exactAlarmSupported: boolean;
  fullScreenIntentSupported: boolean;
  ttsSupported: boolean;
  bypassDndSupported: boolean;
  timeSensitiveSupported: boolean;
  /** 鸿蒙特有：系统代理提醒（reminderAgentManager）是否可用。 */
  agentReminderSupported: boolean;
}

/** 从 MethodCall 的 Map 参数安全解析为 AlertPayload。 */
export function parsePayload(raw: Record<string, Object>): AlertPayload {
  return {
    id: readStr(raw, 'id'),
    kind: readStr(raw, 'kind', AlertKind.PREVIEW),
    fireAt: readNum(raw, 'fireAt'),
    title: readStr(raw, 'title'),
    body: readStr(raw, 'body'),
    voiceText: readStr(raw, 'voiceText'),
    cityId: readStr(raw, 'cityId'),
    cityName: readStr(raw, 'cityName'),
    dateIso: readStr(raw, 'dateIso'),
    plateText: readStr(raw, 'plateText'),
    tailsText: readStr(raw, 'tailsText'),
    timeWindowText: readStr(raw, 'timeWindowText'),
    areaText: readStr(raw, 'areaText'),
  };
}

function readStr(src: Record<string, Object>, key: string, fallback: string = ''): string {
  const v = src[key];
  return typeof v === 'string' ? v : fallback;
}

function readNum(src: Record<string, Object>, key: string, fallback: number = 0): number {
  const v = src[key];
  return typeof v === 'number' ? v : fallback;
}
