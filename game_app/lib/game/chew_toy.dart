import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'tennis_ball.dart';

enum ChewToyType { redBall, blueBone, rope }

class ChewToy extends BodyComponent<PinballGame> with ContactCallbacks {
  static const double radius = 1.35;

  @override
  final Vector2 position;
  final ChewToyType type;
  final void Function(int points) onScored;
  final void Function()? onHitSound;
  double _cooldown = 0;
  double _flashTimer = 0;

  ChewToy({
    required Vector2 position,
    required this.type,
    required this.onScored,
    this.onHitSound,
  }) : position = position.clone(),
       super(renderBody: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final spriteName = switch (type) {
      ChewToyType.redBall => 'sprites/chew_toy_red_ball.png',
      ChewToyType.blueBone => 'sprites/chew_toy_blue_bone.png',
      ChewToyType.rope => 'sprites/chew_toy_rope.png',
    };
    final spriteSize = switch (type) {
      ChewToyType.redBall => Vector2.all(radius * 2.15),
      ChewToyType.blueBone => Vector2(radius * 2.25, radius * 1.05),
      ChewToyType.rope => Vector2(radius * 2.25, radius * 1.65),
    };
    add(
      SpriteComponent(
        sprite: await Sprite.load(spriteName),
        size: spriteSize,
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
      FixtureDef(
        CircleShape()..radius = radius,
        friction: 0.2,
        restitution: 0.7,
      ),
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

    _cooldown = 0.3;
    _flashTimer = 0.28;
    onScored(75);
    onHitSound?.call();
    return true;
  }

  @override
  void render(Canvas canvas) {
    if (_flashTimer <= 0) {
      return;
    }

    final flash = Paint()
      ..color = const Color(0xFFFFF07D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.16
      ..isAntiAlias = false;
    canvas.drawRect(const Rect.fromLTWH(-1.55, -1.18, 3.1, 2.36), flash);
  }
}
