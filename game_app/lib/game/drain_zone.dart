import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'tennis_ball.dart';

class DrainZone extends BodyComponent<PinballGame> with ContactCallbacks {
  final void Function(TennisBall ball) onBallDrained;
  final void Function()? onDrainSound;

  DrainZone({required this.onBallDrained, this.onDrainSound})
    : super(renderBody: false);

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: Vector2(18, 63), userData: this),
    );
    final shape = PolygonShape()..setAsBoxXY(4.5, 2.0);
    body.createFixture(FixtureDef(shape, isSensor: true));
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other case final TennisBall ball) {
      onBallDrained(ball);
      onDrainSound?.call();
    }
  }
}
