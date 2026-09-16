import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/pinball_haptics.dart';
import 'package:pinball_neo_95/game/pinball_world.dart';

void main() {
  test('haptic bus records gameplay feedback without a platform channel', () {
    final haptics = PinballHaptics();

    haptics.light();
    haptics.medium();
    haptics.heavy();

    expect(haptics.events, [
      PinballHaptic.light,
      PinballHaptic.medium,
      PinballHaptic.heavy,
    ]);
    haptics.clear();
    expect(haptics.events, isEmpty);
  });

  test('haptic feedback can be disabled without changing gameplay calls', () {
    final haptics = PinballHaptics()..enabled = false;

    haptics.light();
    haptics.heavy();

    expect(haptics.events, isEmpty);
  });

  test('major table events emit the intended haptic strengths', () {
    final haptics = PinballHaptics();
    final world = PinballWorld(haptics: haptics);

    world.hitPawMissionTarget(0);
    world.activateWaterBonus();
    world.queueBallDrain();

    expect(haptics.events, [PinballHaptic.medium, PinballHaptic.heavy]);
  });
}
