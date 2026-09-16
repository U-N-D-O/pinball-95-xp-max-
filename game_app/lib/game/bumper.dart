import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'tennis_ball.dart';
import 'table_tuning.dart';

enum BumperColor { red, blue }

class Bumper extends BodyComponent<PinballGame> with ContactCallbacks {
  static const double radius = 2.2;

  @override
  final Vector2 position;
  final BumperColor color;
  final void Function(int points) onScored;
  final void Function()? onHitSound;
  double _cooldown = 0;
  double _hitTimer = 0;

  Bumper({
    required Vector2 position,
    required this.color,
    required this.onScored,
    this.onHitSound,
  }) : position = position.clone(),
       super(renderBody: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final spriteName = color == BumperColor.red
        ? 'sprites/bumper_red.png'
        : 'sprites/bumper_blue.png';
    add(
      SpriteComponent(
        sprite: await Sprite.load(spriteName),
        size: Vector2.all(radius * 2.45),
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
        friction: 0.05,
        restitution: 1.0,
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
    if (_hitTimer > 0) {
      _hitTimer -= dt;
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is TennisBall && registerHit()) {
      final away = other.body.position - body.position;
      if (away.length2 > 0) {
        away.normalize();
        other.body.applyLinearImpulse(away * TableTuning.bumperImpulse);
      }
    }
  }

  bool registerHit() {
    if (_cooldown > 0) {
      return false;
    }

    _cooldown = 0.16;
    _hitTimer = 0.24;
    onScored(100);
    onHitSound?.call();
    return true;
  }

  @override
  void render(Canvas canvas) {
    if (_hitTimer > 0) {
      final flash = Paint()
        ..color = const Color(0xFFFFE66B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.22
        ..isAntiAlias = false;
      canvas.drawCircle(Offset.zero, radius + 0.7, flash);
    }
  }
}
