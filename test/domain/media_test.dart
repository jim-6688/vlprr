import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/domain/entities/noise.dart';
import 'package:tail_limit/domain/entities/radio_station.dart';

void main() {
  // 固定基准时刻，避免测试随时钟漂移
  final DateTime base = DateTime(2026, 10, 9, 22, 30);

  group('SleepTimer · 基础', () {
    test('none 为不定时且剩余为零', () {
      expect(SleepTimer.none.isOff, isTrue);
      expect(SleepTimer.none.remaining(base), Duration.zero);
      expect(SleepTimer.none.isExpired(base), isFalse,
          reason: '不定时不应被视为到期');
      expect(SleepTimer.none.progress(base), 0.0);
      expect(SleepTimer.none.volumeFactor(base), 1.0);
    });

    test('fromPreset 以起点推算结束时刻', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes30,
        start: base,
      );
      expect(t.endsAt, base.add(const Duration(minutes: 30)));
      expect(t.totalSeconds, 1800);
      expect(t.isOff, isFalse);
    });

    test('off 预设返回 none', () {
      expect(SleepTimer.fromPreset(SleepTimerPreset.off), SleepTimer.none);
    });

    test('剩余时长随时间递减', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.hour1,
        start: base,
      );
      expect(t.remaining(base), const Duration(hours: 1));
      expect(
        t.remaining(base.add(const Duration(minutes: 25))),
        const Duration(minutes: 35),
      );
      expect(
        t.remaining(base.add(const Duration(hours: 1))),
        Duration.zero,
        reason: '恰好到期时剩余应为 0',
      );
    });

    test('已过期时剩余不再为负', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes15,
        start: base,
      );
      expect(t.isExpired(base.add(const Duration(minutes: 20))), isTrue);
      expect(
        t.remaining(base.add(const Duration(minutes: 20))),
        Duration.zero,
      );
    });
  });

  group('SleepTimer · 进度与渐弱', () {
    test('进度按已流逝比例增长', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes30,
        start: base,
        fadeOutSeconds: 20,
      );
      expect(t.progress(base), 0.0);
      expect(t.progress(base.add(const Duration(minutes: 15))), closeTo(0.5, 0.01));
      expect(t.progress(base.add(const Duration(minutes: 30))), 1.0);
    });

    test('进度被夹在 0–1 之间', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes15,
        start: base,
      );
      // 查询早于起点（时钟回拨）
      expect(t.progress(base.subtract(const Duration(minutes: 5))), 0.0);
      // 查询远超结束时刻
      expect(t.progress(base.add(const Duration(hours: 3))), 1.0);
    });

    test('渐弱区间外音量恒为 1', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes30,
        start: base,
        fadeOutSeconds: 20,
      );
      expect(t.volumeFactor(base), 1.0);
      // 距结束 60 秒，仍在渐弱区间之外
      expect(t.volumeFactor(base.add(const Duration(minutes: 29))), 1.0);
    });

    test('渐弱区间内音量线性下降', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes30,
        start: base,
        fadeOutSeconds: 20,
      );
      // 渐弱区间为 [29:40, 30:00]，每 5 秒采样一次验证线性度
      const <double>[1.0, 0.75, 0.5, 0.25, 0.0].asMap().forEach((int i, double expected) {
        final Duration at = Duration(minutes: 29, seconds: 40 + i * 5);
        expect(
          t.volumeFactor(base.add(at)),
          closeTo(expected, 0.01),
          reason: '第 $i 个采样点（距结束 ${20 - i * 5} 秒）音量应为 $expected',
        );
      });
    });

    test('到期后音量恒为 0', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes15,
        start: base,
        fadeOutSeconds: 20,
      );
      expect(t.volumeFactor(base.add(const Duration(hours: 5))), 0.0);
    });

    test('fadeOutSeconds 为 0 时不渐弱', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes15,
        start: base,
        fadeOutSeconds: 0,
      );
      expect(t.volumeFactor(base.add(const Duration(minutes: 14))), 1.0);
      expect(t.isFading(base.add(const Duration(minutes: 14))), isFalse);
    });

    test('渐弱时长超过总时长时退化为全程渐弱', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes15,
        start: base,
        fadeOutSeconds: 99999,
      );
      // 起点就在渐弱区内，音量应 < 1
      expect(t.volumeFactor(base), lessThan(1.0));
    });

    test('isFading 在渐弱区间内为真', () {
      final SleepTimer t = SleepTimer.fromPreset(
        SleepTimerPreset.minutes30,
        start: base,
        fadeOutSeconds: 20,
      );
      expect(t.isFading(base.add(const Duration(minutes: 10))), isFalse);
      expect(t.isFading(base.add(const Duration(minutes: 29, seconds: 50))),
          isTrue);
      expect(t.isFading(base.add(const Duration(minutes: 30))), isFalse,
          reason: '已到期属于结束而非渐弱');
    });
  });

  group('SleepTimerPreset', () {
    test('时长换算正确', () {
      expect(SleepTimerPreset.minutes15.seconds, 900);
      expect(SleepTimerPreset.minutes30.seconds, 1800);
      expect(SleepTimerPreset.minutes45.seconds, 2700);
      expect(SleepTimerPreset.hour1.seconds, 3600);
      expect(SleepTimerPreset.hours2.seconds, 7200);
      expect(SleepTimerPreset.off.seconds, 0);
    });

    test('off 是唯一 isOff 的预设', () {
      expect(SleepTimerPreset.off.isOff, isTrue);
      for (final SleepTimerPreset p in SleepTimerPreset.values) {
        if (p == SleepTimerPreset.off) continue;
        expect(p.isOff, isFalse, reason: '$p 不应为 off');
      }
    });

    test('全部标签非空', () {
      for (final SleepTimerPreset p in SleepTimerPreset.values) {
        expect(p.label.trim(), isNotEmpty);
      }
    });
  });

  group('NoiseKind', () {
    test('共 8 种音色且label 非空', () {
      expect(NoiseKind.values.length, 8);
      for (final NoiseKind k in NoiseKind.values) {
        expect(k.label.trim(), isNotEmpty);
      }
    });

    test('6 种为合成音，2 种为实录音', () {
      final List<NoiseKind> synth =
          NoiseKind.values.where((NoiseKind k) => k.isSynthesized).toList();
      final List<NoiseKind> recorded =
          NoiseKind.values.where((NoiseKind k) => !k.isSynthesized).toList();

      expect(synth.length, 6);
      expect(recorded.length, 2);
      expect(recorded, containsAll(<NoiseKind>[NoiseKind.waves, NoiseKind.campfire]));
    });

    test('实录音有资源路径，合成音没有', () {
      for (final NoiseKind k in NoiseKind.values) {
        if (k.isSynthesized) {
          expect(k.assetPath, isNull, reason: '$k 是合成音，不该有资源路径');
          expect(k.credit, isNull, reason: '$k 无需署名');
        } else {
          expect(k.assetPath, isNotNull, reason: '$k 缺少资源路径');
          expect(k.assetPath, startsWith('assets/audio/'));
          expect(k.assetPath, endsWith('.ogg'));
          expect(k.credit, isNotNull, reason: '$k 必须有署名信息');
        }
      }
    });

    test('实录音资源路径唯一，避免打包时互相覆盖', () {
      final List<NoiseKind> recorded =
          NoiseKind.values.where((NoiseKind k) => !k.isSynthesized).toList();
      final Set<String> paths =
          recorded.map((NoiseKind k) => k.assetPath!).toSet();
      expect(paths.length, recorded.length);
    });

    test('每条实录音都可追溯到作者、来源与许可', () {
      for (final NoiseKind k in NoiseKind.values) {
        final AudioCredit? c = k.credit;
        if (c == null) continue;
        expect(c.title.trim(), isNotEmpty);
        expect(c.author.trim(), isNotEmpty, reason: '$c 缺作者，署名不完整');
        expect(c.source, startsWith('http'), reason: '$c 缺来源链接');
        expect(c.license.trim(), isNotEmpty);
        expect(c.licenseUrl, startsWith('https://creativecommons.org/'));
      }
    });

    test('CC BY 音源被标记为需要署名', () {
      // 这是合规硬约束：需要署名的必须能在应用内展示出来，
      // 不能只写在源码注释里。
      final Iterable<AudioCredit> credits =
          NoiseKind.values.map((NoiseKind k) => k.credit).whereType<AudioCredit>();
      for (final AudioCredit c in credits) {
        expect(c.requiresAttribution, isTrue,
            reason: '${c.title} 许可为 ${c.license}，必须署名');
      }
    });

    test('长音色的默认时长更长', () {
      // 环境音（雨/海浪等）默认 45 分钟起，纯噪音 30 分钟起
      expect(NoiseKind.rain.defaultDurationSeconds, greaterThan(NoiseKind.white.defaultDurationSeconds));
      expect(NoiseKind.cafe.defaultDurationSeconds, greaterThan(NoiseKind.pink.defaultDurationSeconds));
    });
  });

  group('NoiseSynthesisSpec · 波形合成', () {
    test('样本数量与时长匹配', () {
      final List<double> s = NoiseSynthesisSpec.generate(
        kind: NoiseKind.white,
        sampleRate: 8000,
        durationSeconds: 0.5,
      );
      expect(s.length, 4000);
    });

    test('全部样本在 [-1, 1] 内且无 NaN', () {
      for (final NoiseKind kind in NoiseKind.values) {
        final List<double> samples = NoiseSynthesisSpec.generate(
          kind: kind,
          sampleRate: 8000,
          durationSeconds: 0.2,
          seed: 42,
        );
        expect(samples, isNotEmpty, reason: '$kind 应有样本');
        for (final double v in samples) {
          expect(v.isFinite, isTrue, reason: '$kind 出现 NaN/Inf');
          expect(v, inInclusiveRange(-1.0, 1.0), reason: '$kind 样本越界：$v');
        }
      }
    });

    test('相同种子产生相同波形（可复现）', () {
      final List<double> a = NoiseSynthesisSpec.generate(
        kind: NoiseKind.brown,
        sampleRate: 8000,
        durationSeconds: 0.1,
        seed: 7,
      );
      final List<double> b = NoiseSynthesisSpec.generate(
        kind: NoiseKind.brown,
        sampleRate: 8000,
        durationSeconds: 0.1,
        seed: 7,
      );
      expect(a, equals(b));
    });

    test('不同种子产生不同波形', () {
      final List<double> a = NoiseSynthesisSpec.generate(
        kind: NoiseKind.white,
        sampleRate: 8000,
        durationSeconds: 0.1,
        seed: 1,
      );
      final List<double> b = NoiseSynthesisSpec.generate(
        kind: NoiseKind.white,
        sampleRate: 8000,
        durationSeconds: 0.1,
        seed: 2,
      );
      expect(a, isNot(equals(b)));
    });

    test('时长为 0 返回空列表而非抛异常', () {
      final List<double> s = NoiseSynthesisSpec.generate(
        kind: NoiseKind.white,
        sampleRate: 44100,
        durationSeconds: 0,
      );
      expect(s, isEmpty);
    });

    test('波形非全零（有实际信号）', () {
      for (final NoiseKind kind in NoiseKind.values) {
        final List<double> s = NoiseSynthesisSpec.generate(
          kind: kind,
          sampleRate: 8000,
          durationSeconds: 0.2,
          seed: 3,
        );
        final double peak = s.map((double v) => v.abs()).reduce(math.max);
        expect(peak, greaterThan(0.01), reason: '$kind 峰值过低，疑似静音');
      }
    });

    test('白噪音的频谱能量高于棕噪音（高频更丰富）', () {
      // 用一阶差分的均方根近似高频能量
      double hfEnergy(List<double> s) {
        double sum = 0;
        for (int i = 1; i < s.length; i++) {
          final double d = s[i] - s[i - 1];
          sum += d * d;
        }
        return sum / s.length;
      }

      final List<double> white = NoiseSynthesisSpec.generate(
        kind: NoiseKind.white,
        sampleRate: 8000,
        durationSeconds: 0.5,
        seed: 11,
      );
      final List<double> brown = NoiseSynthesisSpec.generate(
        kind: NoiseKind.brown,
        sampleRate: 8000,
        durationSeconds: 0.5,
        seed: 11,
      );
      expect(
        hfEnergy(white),
        greaterThan(hfEnergy(brown)),
        reason: '棕噪音应比白噪音更暗',
      );
    });

    test('海浪的振幅包络有起伏（非常数直流）', () {
      final List<double> s = NoiseSynthesisSpec.generate(
        kind: NoiseKind.waves,
        sampleRate: 8000,
        durationSeconds: 4.0,
        seed: 5,
      );
      // 分成 4 段比较峰值，应存在明显差异
      final int seg = s.length ~/ 4;
      double peakOf(int from, int to) {
        double p = 0;
        for (int i = from; i < to; i++) {
          final double a = s[i].abs();
          if (a > p) p = a;
        }
        return p;
      }

      final List<double> peaks = [
        peakOf(0, seg),
        peakOf(seg, seg * 2),
        peakOf(seg * 2, seg * 3),
        peakOf(seg * 3, s.length),
      ];
      final double maxP = peaks.reduce(math.max);
      final double minP = peaks.reduce(math.min);
      expect(
        maxP - minP,
        greaterThan(0.01),
        reason: '海浪各段峰值应不同，实测：$peaks',
      );
    });
  });

  group('RadioDirectory · 频道目录', () {
    test('主源非空且至少 5 个频道', () {
      expect(RadioDirectory.primary.length, greaterThanOrEqualTo(5));
    });

    test('所有频道地址为 HLS（m3u8）', () {
      for (final RadioStation s in RadioDirectory.all) {
        expect(s.streamUrl, startsWith('http'), reason: '${s.name} 协议不对');
        expect(s.streamUrl, endsWith('.m3u8'), reason: '${s.name} 非 m3u8');
      }
    });

    test('所有频道走 HTTPS 或已知官方 CDN', () {
      for (final RadioStation s in RadioDirectory.all) {
        final bool secure = s.streamUrl.startsWith('https://');
        final bool officialCdn =
            s.streamUrl.contains('cnr.cn') || s.streamUrl.contains('cri.cn');
        expect(secure || officialCdn, isTrue,
            reason: '${s.name} 既非 HTTPS 也非官方域名：${s.streamUrl}');
      }
    });

    test('频道 id 唯一', () {
      final Set<String> ids = RadioDirectory.all.map((RadioStation s) => s.id).toSet();
      expect(ids.length, RadioDirectory.all.length);
    });

    test('频道名称与频率非空', () {
      for (final RadioStation s in RadioDirectory.all) {
        expect(s.name.trim(), isNotEmpty);
        expect(s.frequency.trim(), isNotEmpty);
        expect(s.description.trim(), isNotEmpty);
      }
    });

    test('byId 能命中且未知 id 返回 null 而非抛异常', () {
      expect(RadioDirectory.byId('zgzs')?.name, '中国之声');
      expect(RadioDirectory.byId('__not_exist__'), isNull);
    });

    test('grouped 覆盖所有频道且分类名匹配', () {
      final Map<RadioCategory, List<RadioStation>> grouped =
          RadioDirectory.grouped;
      final int total = grouped.values
          .fold<int>(0, (int sum, List<RadioStation> v) => sum + v.length);
      expect(total, RadioDirectory.all.length);

      for (final MapEntry<RadioCategory, List<RadioStation>> e in grouped.entries) {
        expect(e.key.label.trim(), isNotEmpty);
        for (final RadioStation s in e.value) {
          expect(s.category, e.key);
        }
      }
    });

    test('至少覆盖新闻与音乐两个分类', () {
      final Set<RadioCategory> cats =
          RadioDirectory.all.map((RadioStation s) => s.category).toSet();
      expect(cats, contains(RadioCategory.news));
      expect(cats, contains(RadioCategory.music));
    });

    test('备源标记正确且默认为空', () {
      expect(RadioDirectory.fallback, isEmpty);
      for (final RadioStation s in RadioDirectory.primary) {
        expect(s.isFallback, isFalse, reason: '${s.name} 不应标记为备用');
      }
    });

    test('User-Agent 非空（部分 CDN 会拒绝空 UA）', () {
      expect(RadioStation.userAgent, isNotEmpty);
      expect(RadioStation.userAgent, contains('Mozilla'));
    });

    test('未知分类标签不重复', () {
      final Set<String> labels =
          RadioCategory.values.map((RadioCategory c) => c.label).toSet();
      expect(labels.length, RadioCategory.values.length);
    });
  });
}
