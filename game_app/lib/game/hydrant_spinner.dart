import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'tennis_ball.dart';

class HydrantSpinner extends BodyComponent<PinballGame> with ContactCallbacks {
  static const double barLength = 5.4;
  static const double barWidth = 0.62;

  @override
  final Vector2 position;
  final void Function(int points) onScored;
  final void Function()? onHitSound;
  late Body _anchorBody;
  late RevoluteJoint _joint;
  double _previousAngle = 0;
  double _rotationProgress = 0;
  double _hitCooldown = 0;

  HydrantSpinner({
    required Vector2 position,
    required this.onScored,
    this.onHitSound,
  }) : position = position.clone(),
       super(
         renderBody: false,
         fixtureDefs: [
           FixtureDef(
             PolygonShape()
               ..setAsBox(barLength / 2, barWidth / 2, Vector2.zero(), 0),
             density: 0.7,
             friction: 0.18,
             restitution: 0.82,
           ),
         ],
         bodyDef: BodyDef(
           type: BodyType.dynamic,
           position: position,
           angularDamping: 0.4,
           allowSleep: false,
         ),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    body.userData = this;
    _previousAngle = body.angle;
    add(
      SpriteComponent(
        sprite: await Sprite.load('sprites/hydrant_spinner.png'),
        size: Vector2(6.0, 3.4),
        anchor: Anchor.center,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );

    _anchorBody = world.createBody(
      BodyDef(type: BodyType.static, position: position.clone()),
    );
    final jointDef = RevoluteJointDef<Body, Body>()
      ..initialize(_anchorBody, body, position.clone())
      ..enableMotor = false;
    _joint = RevoluteJoint(jointDef);
    world.createJoint(_joint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hitCooldown > 0) {
      _hitCooldown -= dt;
    }

    final delta = math.atan2(
      math.sin(body.angle - _previousAngle),
      math.cos(body.angle - _previousAngle),
    );
    _previousAngle = body.angle;
    _rotationProgress += delta.abs();

    while (_rotationProgress >= math.pi * 2) {
      _rotationProgress -= math.pi * 2;
      onScored(1000);
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is TennisBall && registerHit()) {
      final offset = other.body.position - body.position;
      final direction = offset.x >= 0 ? 1.0 : -1.0;
      body.applyAngularImpulse(direction * 3.8);
    }
  }

  bool registerHit() {
    if (_hitCooldown > 0) {
      return false;
    }

    _hitCooldown = 0.18;
    onScored(150);
    onHitSound?.call();
    return true;
  }
}
