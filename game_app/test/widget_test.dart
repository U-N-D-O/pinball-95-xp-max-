import 'dart:ui' show AppLifecycleState;

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/pinball_game.dart';
import 'package:pinball_neo_95/main.dart';
import 'package:pinball_neo_95/pinball_persistence.dart';

void main() {
  testWidgets('renders the pinball game shell', (WidgetTester tester) async {
    await tester.pumpWidget(const PinballApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PinballApp), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
  });

  testWidgets('title screen shows the persisted high score', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const PinballApp(profile: PinballProfile(highScore: 4321)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('HIGH SCORE 0004321'), findsOneWidget);
  });

  testWidgets('opens and closes the mobile settings panel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PinballApp());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('START GAME'));
    await tester.pump();
    await tester.tap(find.byTooltip('Open settings'));
    await tester.pump();
    expect(find.text('SYSTEM SETTINGS'), findsOneWidget);
    expect(find.text('MUTE AUDIO'), findsOneWidget);
    final gameWidget = tester.widget<GameWidget<PinballGame>>(
      find.byType(GameWidget<PinballGame>),
    );
    final game = gameWidget.game!;
    expect(game.paused, isTrue);

    await tester.tap(find.text('CLOSE'));
    await tester.pump();
    expect(find.text('SYSTEM SETTINGS'), findsNothing);
    expect(game.paused, isFalse);
  });

  testWidgets('settings switches expose their labels to accessibility tools', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PinballApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('START GAME'));
    await tester.pump();
    await tester.tap(find.byTooltip('Open settings'));
    await tester.pump();

    expect(find.bySemanticsLabel(RegExp('MUTE AUDIO')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('HAPTIC FEEDBACK')), findsOneWidget);
  });

  testWidgets('pauses and resumes from the mobile pause overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PinballApp());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('START GAME'));
    await tester.pump();
    await tester.tap(find.byTooltip('Pause game'));
    await tester.pump();
    expect(find.text('GAME PAUSED'), findsOneWidget);

    await tester.tap(find.text('RESUME'));
    await tester.pump();
    expect(find.text('GAME PAUSED'), findsNothing);
  });

  testWidgets('pauses safely when the app is backgrounded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PinballApp());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('START GAME'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(find.text('GAME PAUSED'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('GAME PAUSED'), findsOneWidget);

    await tester.tap(find.text('RESUME'));
    await tester.pump();
    expect(find.text('GAME PAUSED'), findsNothing);
  });
}
