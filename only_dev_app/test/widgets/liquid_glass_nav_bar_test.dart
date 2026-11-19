import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_dev_app/widgets/navigation/liquid_glass_nav_bar.dart';

void main() {
  const items = [
    LiquidGlassNavItem(label: 'Home', icon: Icons.home_outlined),
    LiquidGlassNavItem(label: 'Courses', icon: Icons.video_collection_outlined),
    LiquidGlassNavItem(
        label: 'Alerts', icon: Icons.notifications_none, badgeCount: 12),
    LiquidGlassNavItem(label: 'Profile', icon: Icons.person_outline),
  ];

  Widget host({
    required ValueChanged<int> onTap,
    VoidCallback? onTrailing,
    bool blur = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        extendBody: true,
        body: const SizedBox.expand(),
        bottomNavigationBar: LiquidGlassNavBar(
          items: items,
          currentIndex: 0,
          onTap: onTap,
          blur: blur,
          trailingIcon: Icons.search,
          onTrailingTap: onTrailing,
        ),
      ),
    );
  }

  testWidgets('renders labels and iOS-style badge count', (tester) async {
    await tester.pumpWidget(host(onTap: (_) {}));
    for (final item in items) {
      expect(find.text(item.label), findsOneWidget);
    }
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('tapping a tab reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(host(onTap: (i) => tapped = i));
    await tester.tap(find.text('Alerts'));
    expect(tapped, 2);
  });

  testWidgets('blur can be disabled (no BackdropFilter)', (tester) async {
    await tester.pumpWidget(host(onTap: (_) {}, blur: false));
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('selection pill slides on tab change, then settles',
      (tester) async {
    Widget bar(int index) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidGlassNavBar(
              items: items,
              currentIndex: index,
              onTap: (_) {},
            ),
          ),
        );
    Alignment pill() =>
        (tester.widget(find.byType(AnimatedAlign)) as AnimatedAlign).alignment
            as Alignment;

    await tester.pumpWidget(bar(0));
    expect(pill().x, -1);

    await tester.pumpWidget(bar(3));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue); // mid-slide

    await tester.pumpAndSettle();
    expect(pill().x, 1);
    expect(tester.hasRunningAnimations, isFalse); // nothing runs when idle
  });

  testWidgets('plays click sound only when switching to another tab',
      (tester) async {
    final sounds = <Object?>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemSound.play') sounds.add(call.arguments);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(host(onTap: (_) {}));
    await tester.tap(find.text('Home')); // already selected
    expect(sounds, isEmpty);
    await tester.tap(find.text('Courses'));
    expect(sounds, ['SystemSoundType.click']);
  });

  testWidgets('bar zooms up on tab change and settles back to 1',
      (tester) async {
    Widget bar(int index) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidGlassNavBar(
              items: items,
              currentIndex: index,
              onTap: (_) {},
            ),
          ),
        );
    double barScale() {
      final t = tester.widget<Transform>(find
          .descendant(
            of: find.byType(LiquidGlassNavBar),
            matching: find.byType(Transform),
          )
          .first);
      return t.transform.getMaxScaleOnAxis();
    }

    await tester.pumpWidget(bar(0));
    expect(barScale(), 1); // no zoom on first build
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(bar(2));
    await tester.pump(const Duration(milliseconds: 90));
    expect(barScale(), greaterThan(1.02));

    await tester.pumpAndSettle();
    expect(barScale(), closeTo(1, 1e-6));
  });

  testWidgets('trailing button fires its callback', (tester) async {
    var pressed = false;
    await tester
        .pumpWidget(host(onTap: (_) {}, onTrailing: () => pressed = true));
    await tester.tap(find.byIcon(Icons.search));
    expect(pressed, isTrue);
  });
}
