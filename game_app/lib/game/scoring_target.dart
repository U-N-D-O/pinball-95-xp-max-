import 'package:flame_forge2d/flame_forge2d.dart';
import 'dart:ui';

import 'pinball_game.dart';
import 'tennis_ball.dart';

class ScoringTarget extends BodyComponent<PinballGame> with ContactCallbacks {
  static const double width = 2.8;
  static const double height = 0.8;

  @override
  final Vector2 position;
  final void Function(int points) onScored;
  final void Function()? onHitSound;
  double _cooldown = 0;
  double _litTimer = 0;

  ScoringTarget({
    required Vector2 position,
    required this.onScored,
    this.onHitSound,
  }) : position = position.clone(),
       super(renderBody: false);

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: position),
    );
    body.userData = this;
    final shape = PolygonShape()..setAsBoxXY(width / 2, height / 2);
    body.createFixture(FixtureDef(shape, isSensor: true));
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0) {
      _cooldown -= dt;
    }
    if (_litTimer > 0) {
      _litTimer -= dt;
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

    _cooldown = 0.25;
    _litTimer = 0.32;
    onScored(250);
    onHitSound?.call();
    return true;
  }

  @override
  void render(Canvas canvas) {
    final frame = Paint()
      ..color = const Color(0xFF081522)
      ..isAntiAlias = false;
    final target = Paint()
      ..color = _litTimer > 0
          ? const Color(0xFFFFF1A8)
          : const Color(0xFFFFC928)
      ..isAntiAlias = false;

    canvas.drawRect(
      Rect.fromLTWH(
        -width / 2 - 0.18,
        -height / 2 - 0.18,
        width + 0.36,
        height + 0.36,
      ),
      frame,
    );
    canvas.drawRect(
      Rect.fromLTWH(-width / 2, -height / 2, width, height),
      target,
    );
    if (_litTimer > 0) {
      final flash = Paint()
        ..color = const Color(0xFFFFF5C2)
        ..isAntiAlias = false;
      canvas.drawRect(
        Rect.fromLTWH(
          -width / 2 + 0.35,
          -height / 2 + 0.18,
          width - 0.7,
          height - 0.36,
        ),
        flash,
      );
    }
  }
}
