import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/core/router/app_router.dart';
import 'package:tail_limit/core/theme/app_theme.dart';
import 'package:tail_limit/domain/entities/noise.dart';
import 'package:tail_limit/domain/entities/radio_station.dart';
import 'package:tail_limit/domain/repositories/media_gateways.dart';
import 'package:tail_limit/presentation/features/noise/noise_provider.dart';
import 'package:tail_limit/presentation/features/radio/radio_provider.dart';
import 'package:tail_limit/presentation/features/shell/app_shell.dart';

void main() {
  Widget wrap(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: child,
      ),
    );
  }

  group('AppShell · 四栏导航', () {
    testWidgets('渲染今日/广播/白噪音/设置四项', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(const AppShell(location: Routes.home, child: SizedBox())),
      );

      expect(find.text('今日'), findsOneWidget);
      expect(find.text('广播'), findsOneWidget);
      expect(find.text('白噪音'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('当前栏高亮且与其它栏可区分', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(const AppShell(location: Routes.noise, child: SizedBox())),
      );

      final NavigationBar bar =
          tester.widget<NavigationBar>(find.byType(NavigationBar));

      expect(bar.selectedIndex, 2, reason: '白噪音应位于第三栏');
      expect(bar.destinations.length, 4);
      expect(
        bar.destinations
            .cast<NavigationDestination>()
            .map((NavigationDestination d) => d.label)
            .toList(),
        <String>['今日', '广播', '白噪音', '设置'],
      );
    });

    testWidgets('车机版侧栏把限行数据放在独立分组', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(const AppShell(location: Routes.home, child: SizedBox())),
      );

      expect(find.text('限行数据'), findsOneWidget);
      expect(find.text('限行日历'), findsOneWidget);
      expect(find.text('我的车牌'), findsOneWidget);
      expect(find.text('关注城市'), findsOneWidget);
    });

    testWidgets('主导航不再出现日历/车牌/城市', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(const AppShell(location: Routes.home, child: SizedBox())),
      );

      expect(find.text('限行日历'), findsNothing);
      expect(find.text('我的车牌'), findsNothing);
      expect(find.text('关注城市'), findsNothing);
    });
  });

  group('RadioPlaybackController · 状态机', () {
    /// 网关通过 Stream 上报状态，事件派发是异步的。
    ///
    /// 因此每次驱动播放动作后必须把事件队列排空，否则读到的还是
    /// 上一个状态（这正是真实播放链路的行为，测试不能绕过它）。
    Future<void> settle() => pumpEventQueue();

    test('初始为空闲', () {
      final SimulatedRadioGateway gateway = SimulatedRadioGateway();
      final RadioPlaybackController c = RadioPlaybackController(gateway);
      addTearDown(c.dispose);

      expect(c.state.state, RadioPlaybackState.idle);
      expect(c.state.station, isNull);
      expect(c.state.isPlaying, isFalse);
    });

    test('播放成功后进入 playing 并带回频道', () async {
      final SimulatedRadioGateway gateway =
          SimulatedRadioGateway(connectLatency: Duration.zero);
      final RadioPlaybackController c = RadioPlaybackController(gateway);
      addTearDown(c.dispose);

      final RadioStation station = RadioDirectory.all.first;
      await c.play(station);
      await settle();

      expect(c.state.state, RadioPlaybackState.playing);
      expect(c.state.station?.id, station.id);
      expect(c.state.isPlaying, isTrue);
    });

    test('播放失败进入 error 并给出中文原因', () async {
      final SimulatedRadioGateway gateway =
          SimulatedRadioGateway(connectLatency: Duration.zero);
      gateway.failNextPlay = true;
      final RadioPlaybackController c = RadioPlaybackController(gateway);
      addTearDown(c.dispose);

      await expectLater(
        c.play(RadioDirectory.all.first),
        throwsA(isA<RadioPlaybackException>()),
      );
      await settle();

      expect(c.state.state, RadioPlaybackState.error);
      expect(c.state.errorReason, isNotEmpty);
      expect(c.state.isPlaying, isFalse);
    });

    test('toggle 在播放与暂停间切换', () async {
      final SimulatedRadioGateway gateway =
          SimulatedRadioGateway(connectLatency: Duration.zero);
      final RadioPlaybackController c = RadioPlaybackController(gateway);
      addTearDown(c.dispose);

      await c.play(RadioDirectory.all.first);
      await settle();
      expect(c.state.state, RadioPlaybackState.playing);

      await c.toggle();
      await settle();
      expect(c.state.state, RadioPlaybackState.paused);

      await c.toggle();
      await settle();
      expect(c.state.state, RadioPlaybackState.playing);
    });

    test('stop 后回到初始快照', () async {
      final SimulatedRadioGateway gateway =
          SimulatedRadioGateway(connectLatency: Duration.zero);
      final RadioPlaybackController c = RadioPlaybackController(gateway);
      addTearDown(c.dispose);

      await c.play(RadioDirectory.all.first);
      await c.stop();
      await settle();

      expect(c.state.state, RadioPlaybackState.idle);
      expect(c.state.station, isNull);
    });

    test('error 状态下 toggle 会重播同一频道', () async {
      final SimulatedRadioGateway gateway =
          SimulatedRadioGateway(connectLatency: Duration.zero);
      final RadioPlaybackController c = RadioPlaybackController(gateway);
      addTearDown(c.dispose);

      final RadioStation station = RadioDirectory.all.first;
      gateway.failNextPlay = true;
      await c.play(station).onError((_, __) {});
      await settle();
      expect(c.state.state, RadioPlaybackState.error);

      // 重播应成功——errorReason 必须被清掉，否则界面会一直挂错误条
      await c.toggle();
      await settle();
      expect(c.state.state, RadioPlaybackState.playing);
      expect(c.state.errorReason, isNull);
      expect(c.state.station?.id, station.id);
    });
  });

  group('NoisePlaybackController · 定时与渐弱', () {
    NoisePlaybackController build(
      SimulatedNoiseGateway gateway,
      DateTime now,
    ) {
      final NoisePlaybackController c = NoisePlaybackController(gateway);
      c.now = () => now;
      return c;
    }

    test('未播放时不定时且剩余为零', () {
      final NoisePlaybackController c = build(
        SimulatedNoiseGateway(),
        DateTime(2026, 10, 9, 22, 30),
      );
      addTearDown(c.dispose);

      expect(c.state.kind, isNull);
      expect(c.state.isPlaying, isFalse);
      expect(c.state.hasTimer, isFalse);
      expect(c.state.remaining, Duration.zero);
      expect(c.state.remainingLabel, '');
    });

    test('播放后自动起默认定时', () async {
      final DateTime base = DateTime(2026, 10, 9, 22, 30);
      final NoisePlaybackController c =
          build(SimulatedNoiseGateway(), base);
      addTearDown(c.dispose);

      await c.play(NoiseKind.rain);

      expect(c.state.kind, NoiseKind.rain);
      expect(c.state.isPlaying, isTrue);
      expect(c.state.hasTimer, isTrue,
          reason: '未手动定时时应按推荐时长兜底，避免长音无限播放');
      expect(c.state.remainingMinutes, greaterThan(0));
    });

    test('已有定时时不因重新播放而被覆盖', () async {
      final DateTime base = DateTime(2026, 10, 9, 22, 30);
      final NoisePlaybackController c =
          build(SimulatedNoiseGateway(), base);
      addTearDown(c.dispose);

      await c.play(NoiseKind.white);
      await c.setTimerPreset(SleepTimerPreset.minutes15);
      final int before = c.state.timer!.totalSeconds;

      await c.play(NoiseKind.pink);

      expect(c.state.timer!.totalSeconds, before,
          reason: '用户显式设过的定时不该被自动兜底改写');
    });

    test('setTimerPreset(off) 取消定时', () async {
      final DateTime base = DateTime(2026, 10, 9, 22, 30);
      final NoisePlaybackController c =
          build(SimulatedNoiseGateway(), base);
      addTearDown(c.dispose);

      await c.play(NoiseKind.white);
      expect(c.state.hasTimer, isTrue);

      await c.setTimerPreset(SleepTimerPreset.off);

      expect(c.state.hasTimer, isFalse);
      expect(c.state.remaining, Duration.zero);
    });

    test('暂停后定时保留，恢复后继续', () async {
      final DateTime base = DateTime(2026, 10, 9, 22, 30);
      final NoisePlaybackController c =
          build(SimulatedNoiseGateway(), base);
      addTearDown(c.dispose);

      await c.play(NoiseKind.waves);
      await c.setTimerPreset(SleepTimerPreset.minutes30);

      await c.pause();
      expect(c.state.isPlaying, isFalse);
      expect(c.state.hasTimer, isTrue);
      expect(c.state.remainingLabel, '已暂停');

      await c.resume();
      expect(c.state.isPlaying, isTrue);
      expect(c.state.hasTimer, isTrue);
    });

    test('stop 清空定时与播放态', () async {
      final DateTime base = DateTime(2026, 10, 9, 22, 30);
      final NoisePlaybackController c =
          build(SimulatedNoiseGateway(), base);
      addTearDown(c.dispose);

      await c.play(NoiseKind.cafe);
      await c.stop();

      expect(c.state.isPlaying, isFalse);
      expect(c.state.hasTimer, isFalse);
      expect(c.state.kind, NoiseKind.cafe,
          reason: '停止后保留当前音效，便于用户直接重播');
    });

    test('音量被夹在 0–1', () async {
      final NoisePlaybackController c = build(
        SimulatedNoiseGateway(),
        DateTime(2026, 10, 9, 22, 30),
      );
      addTearDown(c.dispose);

      await c.setVolume(-1);
      expect(c.state.volume, 0.0);

      await c.setVolume(5);
      expect(c.state.volume, 1.0);

      await c.setVolume(0.4);
      expect(c.state.volume, closeTo(0.4, 0.001));
    });

    test('定时到期后停止播放并清空定时', () async {
      final DateTime base = DateTime(2026, 10, 9, 22, 30);
      final SimulatedNoiseGateway gateway = SimulatedNoiseGateway();
      final NoisePlaybackController c = NoisePlaybackController(gateway);
      addTearDown(c.dispose);

      // 用可推进的假时钟，避免真的等 15 分钟
      DateTime clock = base;
      c.now = () => clock;

      await c.play(NoiseKind.pink);
      await c.setTimerPreset(SleepTimerPreset.minutes15);
      expect(c.state.isPlaying, isTrue);

      // 推进到渐弱区间内，音量应开始下降
      clock = base.add(const Duration(minutes: 14, seconds: 50));
      c.debugTick();
      expect(c.state.volume, lessThan(1.0));
      expect(c.state.isPlaying, isTrue);

      // 推进到到期
      clock = base.add(const Duration(minutes: 15, seconds: 1));
      c.debugTick();

      expect(c.state.isPlaying, isFalse);
      expect(c.state.hasTimer, isFalse);
      expect(c.state.volume, 0.0);
    });
  });
}