import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { AlertPayload } from './AlertModels';

/**
 * 提醒载荷持久化。
 *
 * 用途：设备重启后 `reminderAgentManager` 的系统代理提醒会被系统保留，
 * 但为了在"取消全部"、"配置变更重排"时能准确比对，仍需要本地事实源。
 * 使用 Preferences 存储 JSON 字符串，避免引入关系型数据库依赖。
 */
export class AlertStore {
  private static readonly STORE_NAME: string = 'tail_limit_alert_store';
  private static readonly KEY_SCHEDULED: string = 'scheduled_payloads';

  private store: preferences.Preferences | null = null;
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /** 惰性初始化 Preferences（首次访问时打开）。 */
  private async ensureStore(): Promise<preferences.Preferences> {
    if (this.store === null) {
      this.store = await preferences.getPreferences(this.context, AlertStore.STORE_NAME);
    }
    return this.store;
  }

  /** 读取全部已排程载荷。 */
  async loadAll(): Promise<AlertPayload[]> {
    const store = await this.ensureStore();
    const raw = await store.get(AlertStore.KEY_SCHEDULED, '[]');
    if (typeof raw !== 'string' || raw.length === 0) {
      return [];
    }
    try {
      const parsed = JSON.parse(raw) as AlertPayload[];
      return Array.isArray(parsed) ? parsed : [];
    } catch (e) {
      // 数据损坏时返回空列表，避免阻塞排程流程
      return [];
    }
  }

  /** 覆盖写入全部载荷。 */
  async saveAll(payloads: AlertPayload[]): Promise<void> {
    const store = await this.ensureStore();
    await store.put(AlertStore.KEY_SCHEDULED, JSON.stringify(payloads));
    await store.flush();
  }

  /** 按 ID 新增或更新单条载荷。 */
  async upsert(payload: AlertPayload): Promise<void> {
    const all = await this.loadAll();
    const idx = all.findIndex((p) => p.id === payload.id);
    if (idx >= 0) {
      all[idx] = payload;
    } else {
      all.push(payload);
    }
    await this.saveAll(all);
  }

  /** 按 ID 批量删除。 */
  async remove(ids: string[]): Promise<void> {
    if (ids.length === 0) {
      return;
    }
    const idSet = new Set<string>(ids);
    const all = await this.loadAll();
    const kept = all.filter((p) => !idSet.has(p.id));
    await this.saveAll(kept);
  }

  /** 清空全部。 */
  async clear(): Promise<void> {
    await this.saveAll([]);
  }
}
