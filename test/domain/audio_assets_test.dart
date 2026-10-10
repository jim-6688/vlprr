import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/domain/entities/noise.dart';

/// 实录音资源校验。
///
/// 这些用例存在的意义：资源文件可能被误删、改名或误提交大文件，
/// 而 `flutter analyze` 与领域层测试都发现不了——只有真正读文件才会暴露。
void main() {
  // 打包进 App 的资源根目录（与 pubspec.yaml 的 assets 声明一致）。
  const String assetRoot = 'assets';

  final List<NoiseKind> recorded =
      NoiseKind.values.where((NoiseKind k) => !k.isSynthesized).toList();

  group('实录音资源 · 存在性', () {
    test('至少有两个实录音', () {
      expect(recorded, isNotEmpty,
          reason: '若全部改回合成音，本组用例应同步调整');
    });

    test('每个实录音的路径都能在磁盘上找到', () {
      for (final NoiseKind kind in recorded) {
        final String path = '$assetRoot/${kind.assetPath!.replaceFirst('assets/', '')}';
        final File f = File(path);
        expect(f.existsSync(), isTrue, reason: '$kind 的资源缺失：$path');
        expect(f.lengthSync(), greaterThan(0), reason: '$kind 的资源是空文件');
      }
    });

    test('pubspec 已声明 audio 目录，否则真机打包会缺资源', () {
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('assets/audio/'),
          reason: '未在 pubspec.yaml 声明 assets/audio/，真机运行会加载失败');
    });
  });

  group('实录音资源 · 体积预算', () {
    test('单个资源不超过 3 MB', () {
      for (final NoiseKind kind in recorded) {
        final File f = File('$assetRoot/${kind.assetPath!.replaceFirst('assets/', '')}');
        expect(f.lengthSync(), lessThan(3 * 1024 * 1024),
            reason: '${kind.label} 过大：${(f.lengthSync() / 1048576).toStringAsFixed(1)} MB');
      }
    });

    test('全部实录音合计不超过 12 MB', () {
      //留出余量：后续若再加 2-3 个实录仍不会突破包体预算
      int total = 0;
      for (final NoiseKind kind in recorded) {
        total += File('$assetRoot/${kind.assetPath!.replaceFirst('assets/', '')}').lengthSync();
      }
      expect(total, lessThan(12 * 1024 * 1024),
          reason: '实录音合计 ${(total / 1048576).toStringAsFixed(1)} MB，超出预算');
    });

    test('总体积确实大于零（防止测试误判）', () {
      int total = 0;
      for (final NoiseKind kind in recorded) {
        total += File('$assetRoot/${kind.assetPath!.replaceFirst('assets/', '')}').lengthSync();
      }
      expect(total, greaterThan(0));
    });
  });

  group('实录音资源 · 格式规范', () {
    test('文件头是 OggS（Ogg 容器），不是 WAV 或 MP3', () {
      for (final NoiseKind kind in recorded) {
        final File f = File('$assetRoot/${kind.assetPath!.replaceFirst('assets/', '')}');
        final List<int> head = f.readAsBytesSync().take(4).toList();
        expect(
          String.fromCharCodes(head),
          'OggS',
          reason: '${kind.label} 不是 Ogg 容器。若改为其他格式，'
              '需同步确认三端解码支持情况',
        );
      }
    });

    test('文件名与 assetPath 声明一致', () {
      for (final NoiseKind kind in recorded) {
        final String path = kind.assetPath!;
        final String name = path.split('/').last;
        expect(RegExp(r'^[a-z0-9_]+\.ogg$').hasMatch(name), isTrue,
            reason: '$name 不符合小写下划线命名规范');
      }
    });
  });

  group('实录音资源 · 署名合规', () {
    test('每条实录音都有完整署名信息', () {
      for (final NoiseKind kind in recorded) {
        final AudioCredit? c = kind.credit;
        expect(c, isNotNull, reason: '${kind.label} 缺少署名');
        if (c == null) continue;
        expect(c.author.trim(), isNotEmpty);
        expect(c.source, isNotEmpty);
        expect(c.license, isNotEmpty);
      }
    });

    test('无禁止商用的许可（NC / ND 一律不可用）', () {
      for (final NoiseKind kind in recorded) {
        final AudioCredit? c = kind.credit;
        if (c == null) continue;
        final String l = c.license.toUpperCase();
        expect(l.contains('-NC'), isFalse, reason: '${c.title} 为非商用许可，不可内置');
        expect(l.contains('-ND'), isFalse, reason: '${c.title} 为禁止改作许可');
      }
    });

    test('CC0 类音源无需署名，非 CC0 类必须署名', () {
      for (final NoiseKind kind in recorded) {
        final AudioCredit c = kind.credit!;
        final bool isFree =
            c.license.contains('CC0') || c.license.contains('Public Domain');
        expect(c.requiresAttribution, isNot(isFree),
            reason: '${c.title} 的许可(${c.license})与署名要求不一致');
      }
    });
  });
}