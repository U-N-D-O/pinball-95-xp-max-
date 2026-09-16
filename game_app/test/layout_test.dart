import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/main.dart';
import 'package:pinball_neo_95/pinball_pause.dart';
import 'package:pinball_neo_95/pinball_settings.dart';
import 'package:pinball_neo_95/pinball_title.dart';

void main() {
  testWidgets('title screen fits common portrait phone sizes', (
    WidgetTester tester,
  ) async {
    for (final size in [const Size(360, 640), const Size(390, 844)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const PinballApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PinballTitlePanel), findsOneWidget);
      expect(tester.getSize(find.byType(PinballTitlePanel)), size);
      expect(tester.takeException(), isNull);
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('settings and pause overlays fit a compact portrait phone', (
    WidgetTester tester,
  ) async {
    const size = Size(360, 640);
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(const PinballApp());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('START GAME'));
    await tester.pump();
    await tester.tap(find.byTooltip('Open settings'));
    await tester.pump();
    expect(find.byType(PinballSettingsPanel), findsOneWidget);
    expect(tester.getSize(find.byType(PinballSettingsPanel)), size);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('CLOSE'));
    await tester.pump();
    await tester.tap(find.byTooltip('Pause game'));
    await tester.pump();
    expect(find.byType(PinballPausePanel), findsOneWidget);
    expect(tester.getSize(find.byType(PinballPausePanel)), size);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });
}
