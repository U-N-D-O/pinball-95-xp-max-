import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/table_tuning.dart';
import 'package:pinball_neo_95/game/tennis_ball.dart';

void main() {
  test('ball velocity cap preserves safe speeds and limits runaway speeds', () {
    final safe = Vector2(3, 4);
    final capped = TennisBall.capVelocity(Vector2(0, 40));

    expect(TennisBall.capVelocity(safe), safe);
    expect(capped.x, closeTo(0, 0.0001));
    expect(capped.y, closeTo(TableTuning.ballMaxSpeed, 0.0001));
    expect(capped.length, closeTo(TableTuning.ballMaxSpeed, 0.0001));
  });

  test(
    'table tuning keeps the launch within the intended playable envelope',
    () {
      expect(TableTuning.gravity, greaterThan(0));
      expect(TableTuning.ballRestitution, inInclusiveRange(0.0, 1.0));
      expect(TableTuning.ballMaxSpeed, greaterThan(25));
      expect(TableTuning.ballMaxSpeed, lessThan(45));
      expect(TableTuning.launcherVerticalSpeed, lessThan(-20));
      expect(TableTuning.bumperImpulse, greaterThan(0));
    },
  );
}
