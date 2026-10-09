import textToSpeech from '@ohos.ai.tts';
import { BusinessError } from '@ohos.base';

/**
 * 中文语音合成（强提醒触发时朗读车牌与限行尾号）。
 *
 * 鸿蒙 TTS 采用 createEngine → 创建引擎 → speak 的流程，
 * 引擎创建较慢（约数百毫秒），因此首次调用后缓存实例。
 */
export class TtsSpeaker {
  private static engine: textToSpeech.TextToSpeechEngine | null = null;
  private static initializing: boolean = false;

  /** 惰性创建引擎。 */
  private static async ensureEngine(): Promise<textToSpeech.TextToSpeechEngine | null> {
    if (TtsSpeaker.engine !== null) {
      return TtsSpeaker.engine;
    }
    if (TtsSpeaker.initializing) {
      return null;
    }
    TtsSpeaker.initializing = true;
    try {
      const params: textToSpeech.CreateEngineParams = {
        language: 'zh-CN',
        person: 0,
        online: 0,
      };
      TtsSpeaker.engine = await textToSpeech.createEngine(params);
      return TtsSpeaker.engine;
    } catch (e) {
      const err = e as BusinessError;
      console.error(`[TtsSpeaker] 引擎创建失败：${err.code} ${err.message}`);
      return null;
    } finally {
      TtsSpeaker.initializing = false;
    }
  }

  /**
   * 播报一段文本。
   *
   * @param text 待播报内容（中文）
   * @returns 是否成功发起播报
   */
  static async speak(text: string): Promise<boolean> {
    if (text.length === 0) {
      return false;
    }
    const engine = await TtsSpeaker.ensureEngine();
    if (engine === null) {
      return false;
    }
    try {
      // speed: 语速 0.0-2.0，0.95 接近自然语速
      await engine.speak(text, { speed: 0.95, volume: 1.0, pitch: 1.0, languageContext: 'zh-CN' });
      return true;
    } catch (e) {
      const err = e as BusinessError;
      console.error(`[TtsSpeaker] 播报失败：${err.code} ${err.message}`);
      return false;
    }
  }

  /** 停止播报。 */
  static async stop(): Promise<void> {
    if (TtsSpeaker.engine === null) {
      return;
    }
    try {
      await TtsSpeaker.engine.stop();
    } catch (e) {
      // 忽略
    }
  }

  /** 释放引擎（应用退出时调用）。 */
  static async release(): Promise<void> {
    if (TtsSpeaker.engine === null) {
      return;
    }
    try {
      await TtsSpeaker.engine.shutdown();
    } catch (e) {
      // 忽略
    }
    TtsSpeaker.engine = null;
  }
}
