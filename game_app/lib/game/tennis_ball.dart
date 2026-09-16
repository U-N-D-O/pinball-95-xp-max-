import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'table_tuning.dart';

class TennisBall extends BodyComponent<PinballGame> {
  static const double radius = 0.9;
  static const int renderPriority = 210;

  // The launcher lane is drawn by LauncherControl at priority 200. Keep the
  // ball above that decorative lane so the ready ball is visible to the
  // player instead of being painted underneath the lane artwork.
  static Vector2 get launcherPosition => Vector2(32.8, 58.5);

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
          position: (initialPosition ?? launcherPosition).clone(),
          bullet: true,
          angularDamping: 0.35,
          linearDamping: TableTuning.ballLinearDamping,
        ),
        priority: renderPriority,
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

  void launch({double strength = 1.0}) {
    if (_launched) {
      return;
    }

    final launchStrength = strength.clamp(0.0, 1.0).toDouble();
    final effectiveStrength =
        TableTuning.launcherMinimumStrength +
        ((1.0 - TableTuning.launcherMinimumStrength) * launchStrength);
    body.setTransform(Vector2(28.5, 54.0), 0);
    body.gravityScale = Vector2.all(1);
    body.setAwake(true);
    body.linearVelocity = Vector2(
      TableTuning.launcherHorizontalSpeed * effectiveStrength,
      TableTuning.launcherVerticalSpeed * effectiveStrength,
    );
    _launched = true;
  }
}
