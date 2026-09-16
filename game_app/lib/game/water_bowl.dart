import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'tennis_ball.dart';

class WaterBowl extends BodyComponent<PinballGame> with ContactCallbacks {
  static const double radius = 2.3;

  @override
  final Vector2 position;
  final void Function() onActivated;
  final void Function()? onHitSound;
  double _cooldown = 0;
  double _flashTimer = 0;

  WaterBowl({
    required Vector2 position,
    required this.onActivated,
    this.onHitSound,
  }) : position = position.clone(),
       super(renderBody: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      SpriteComponent(
        sprite: await Sprite.load('sprites/water_bowl.png'),
        size: Vector2.all(radius * 2.2),
        anchor: Anchor.center,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );
  }

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: position),
    );
    body.userData = this;
    body.createFixture(
      FixtureDef(CircleShape()..radius = radius, isSensor: true),
    );
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0) {
      _cooldown -= dt;
    }
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is TennisBall) {
      registerHit();
    }
  }

  bool registerHit() {
    if (_cooldown > 0) {
      return false;
    }

    _cooldown = 0.75;
    _flashTimer = 0.5;
    onActivated();
    onHitSound?.call();
    return true;
  }

  @override
  void render(Canvas canvas) {
    if (_flashTimer > 0 || game.world.waterBonusActive) {
      final flash = Paint()
        ..color = const Color(0xFFB9FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2
        ..isAntiAlias = false;
      canvas.drawCircle(Offset.zero, radius + 0.6, flash);
    }
  }
}
