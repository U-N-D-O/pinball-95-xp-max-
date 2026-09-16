import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/pinball_telemetry.dart';
import 'package:pinball_neo_95/game/pinball_world.dart';

void main() {
  test('telemetry counts events and totals their values', () {
    final telemetry = PinballTelemetry();

    telemetry.record('score_awarded', value: 100);
    telemetry.record('score_awarded', value: 250);
    telemetry.record('ball_drained');

    expect(telemetry.count('score_awarded'), 2);
    expect(telemetry.totalValue('score_awarded'), 350);
    expect(telemetry.count('ball_drained'), 1);

    telemetry.clear();
    expect(telemetry.events, isEmpty);
  });

  test('world telemetry tracks important gameplay milestones', () {
    final world = PinballWorld();

    world.addScore(250);
    world.activateWaterBonus();
    world.hitPawMissionTarget(0);
    world.queueBallDrain();

    expect(world.telemetry.totalValue('score_awarded'), 1250);
    expect(world.telemetry.count('water_bonus'), 1);
    expect(world.telemetry.count('paw_mission_hit'), 1);
    expect(world.telemetry.count('ball_drained'), 1);
  });

  test(
    'performance monitor identifies slow frames without false positives',
    () {
      final performance = PinballPerformance();

      performance.sample(1 / 60);
      performance.sample(1 / 60);
      performance.sample(0.1);

      expect(performance.frames, 3);
      expect(performance.slowFrames, 1);
      expect(performance.maxFrameSeconds, 0.1);
      expect(
        performance.averageFrameSeconds,
        closeTo((1 / 60 + 1 / 60 + 0.1) / 3, 0.00001),
      );
    },
  );
}
