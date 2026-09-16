import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/flipper.dart';
import 'package:pinball_neo_95/game/launcher.dart';
import 'package:pinball_neo_95/game/pinball_game.dart';
import 'package:pinball_neo_95/game/tennis_ball.dart';

void main() {
  test('portrait touch zones cover the lower playfield without overlap', () {
    final leftFlipper = PinballFlipper(isLeft: true, pivot: Vector2(8, 58));
    final rightFlipper = PinballFlipper(isLeft: false, pivot: Vector2(28, 58));
    final leftZone = FlipperControlZone(flipper: leftFlipper, isLeft: true);
    final rightZone = FlipperControlZone(flipper: rightFlipper, isLeft: false);
    final launcher = LauncherControl(ball: TennisBall(), canLaunch: () => true);

    expect(leftZone.position, Vector2(0, 48));
    expect(leftZone.size, Vector2(18, 16));
    expect(rightZone.position, Vector2(18, 48));
    expect(rightZone.size, Vector2(12.8, 16));
    expect(launcher.position, Vector2(30.8, 48));
    expect(launcher.size, Vector2(5.2, 16));
    expect(leftZone.position.x + leftZone.size.x, rightZone.position.x);
    expect(
      rightZone.position.x + rightZone.size.x,
      closeTo(launcher.position.x, 0.0001),
    );
    expect(
      launcher.position.x + launcher.size.x,
      closeTo(PinballGame.worldWidth, 0.0001),
    );
    expect(TennisBall.renderPriority, greaterThan(launcher.priority));
  });

  test('a ball defaults to the visible launcher position', () {
    final ball = TennisBall();

    expect(ball.bodyDef!.position, TennisBall.launcherPosition);
  });

  test(
    'touch control press and release state is safe before physics loads',
    () {
      final flipper = PinballFlipper(isLeft: true, pivot: Vector2(8, 58));
      final zone = FlipperControlZone(flipper: flipper, isLeft: true);

      zone.press();
      expect(flipper.isPressed, isTrue);
      zone.release();
      expect(flipper.isPressed, isFalse);
    },
  );

  test('launcher touch action respects its launch gate', () {
    final launcher = LauncherControl(
      ball: TennisBall(),
      canLaunch: () => false,
    );

    expect(() => launcher.launch(), returnsNormally);
  });
}
