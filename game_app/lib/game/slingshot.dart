import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'table_tuning.dart';
import 'tennis_ball.dart';

class PinballSlingshot extends BodyComponent<PinballGame>
    with ContactCallbacks {
  static const double width = 7.0;
  static const double height = 3.2;
  static const int scoreValue = 50;

  @override
  final Vector2 position;
  final bool isLeft;
  final void Function(int points) onScored;
  final void Function()? onHitSound;
  double _cooldown = 0;
  double _hitTimer = 0;

  PinballSlingshot({
    required Vector2 position,
    required this.isLeft,
    required this.onScored,
    this.onHitSound,
  }) : position = position.clone(),
       super(renderBody: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = SpriteComponent(
      sprite: await Sprite.load('sprites/slingshot_left.png'),
      size: Vector2(width + 1.0, height + 2.0),
      anchor: Anchor.center,
      paint: Paint()..filterQuality = FilterQuality.none,
    );
    if (!isLeft) {
      sprite.flipHorizontallyAroundCenter();
    }
    add(sprite);
  }

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: position),
    );
    body.userData = this;

    final inwardTip = isLeft ? 2.6 : -2.6;
    final shape = PolygonShape()
      ..set([
        Vector2(-width / 2, height / 2),
        Vector2(width / 2, height / 2),
        Vector2(inwardTip, -height / 2),
      ]);
    body.createFixture(FixtureDef(shape, friction: 0.18, restitution: 0.72));
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
      _kickBall(other);
    }
  }

  bool registerHit() {
    if (_cooldown > 0) {
      return false;
    }

    _cooldown = 0.22;
    _hitTimer = 0.18;
    onScored(scoreValue);
    onHitSound?.call();
    return true;
  }

  void _kickBall(TennisBall ball) {
    final direction = (isLeft ? Vector2(0.72, -0.7) : Vector2(-0.72, -0.7))
        .normalized();
    final velocity = ball.body.linearVelocity.clone();
    final currentKickSpeed = velocity.dot(direction);
    final requiredKickSpeed =
        TableTuning.slingshotMinimumOutwardSpeed - currentKickSpeed;
    if (requiredKickSpeed > 0) {
      velocity += direction * requiredKickSpeed;
    }
    ball.body.linearVelocity = velocity;
    ball.body.applyLinearImpulse(direction * TableTuning.slingshotImpulse);
    ball.body.linearVelocity = TennisBall.capVelocity(ball.body.linearVelocity);
    ball.body.setAwake(true);
  }

  @override
  void render(Canvas canvas) {
    if (_hitTimer <= 0) {
      return;
    }

    final flash = Paint()
      ..color = const Color(0xFFFFE66B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.18
      ..isAntiAlias = false;
    canvas.drawRect(const Rect.fromLTWH(-3.8, -2.0, 7.6, 4.0), flash);
  }
}
