import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';

class BoneRamp extends BodyComponent<PinballGame> {
  final Vector2 start;
  final Vector2 end;
  final double width;
  final Color accentColor;
  late final double length;

  BoneRamp({
    required Vector2 start,
    required Vector2 end,
    this.width = 0.72,
    this.accentColor = const Color(0xFFD4473F),
  }) : start = start.clone(),
       end = end.clone(),
       super(renderBody: false) {
    length = math.sqrt(
      math.pow(end.x - this.start.x, 2) + math.pow(end.y - this.start.y, 2),
    );
  }

  @override
  Vector2 get center => Vector2((start.x + end.x) / 2, (start.y + end.y) / 2);

  double get rampAngle => math.atan2(end.y - start.y, end.x - start.x);

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: center, angle: rampAngle),
    );
    final shape = PolygonShape()
      ..setAsBox(length / 2, width / 2, Vector2.zero(), 0);
    body.createFixture(FixtureDef(shape, friction: 0.22, restitution: 0.58));
    return body;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      SpriteComponent(
        sprite: await Sprite.load('sprites/bone_ramp.png'),
        size: Vector2(length + width * 1.8, width * 1.8),
        anchor: Anchor.center,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );
  }
}
