import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'table_tuning.dart';

class TennisBall extends BodyComponent<PinballGame> {
  static const double radius = 0.9;
  static final Vector2 launcherPosition = Vector2(32.8, 58.5);
  bool _launched = false;

  bool get isReadyToLaunch => !_launched;

  TennisBall({Vector2? initialPosition})
    : super(
        renderBody: false,
        fixtureDefs: [
          FixtureDef(
            CircleShape()..radius = radius,
            density: 0.55,
            friction: 0.08,
            restitution: TableTuning.ballRestitution,
          ),
        ],
        bodyDef: BodyDef(
          type: BodyType.dynamic,
          position: initialPosition ?? Vector2(16, 17),
          bullet: true,
          angularDamping: 0.35,
          linearDamping: TableTuning.ballLinearDamping,
        ),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    body.userData = this;
    add(
      SpriteComponent(
        sprite: await Sprite.load('sprites/ball_tennis_idle.png'),
        size: Vector2.all(radius * 2.5),
        anchor: Anchor.center,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );
    parkAtLauncher();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (body.linearVelocity.length2 >
        TableTuning.ballMaxSpeed * TableTuning.ballMaxSpeed) {
      body.linearVelocity = capVelocity(body.linearVelocity);
    }
  }

  static Vector2 capVelocity(Vector2 velocity) {
    final capped = velocity.clone();
    if (capped.length2 > TableTuning.ballMaxSpeed * TableTuning.ballMaxSpeed) {
      capped.normalize();
      capped.scale(TableTuning.ballMaxSpeed);
    }
    return capped;
  }

  void parkAtLauncher() {
    body.setTransform(launcherPosition.clone(), 0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
    body.gravityScale = Vector2.zero();
    body.setAwake(false);
    _launched = false;
  }

  void launch() {
    if (_launched) {
      return;
    }

    body.setTransform(Vector2(28.5, 54.0), 0);
    body.gravityScale = Vector2.all(1);
    body.setAwake(true);
    body.linearVelocity = Vector2(
      TableTuning.launcherHorizontalSpeed,
      TableTuning.launcherVerticalSpeed,
    );
    _launched = true;
  }
}
