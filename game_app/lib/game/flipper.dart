import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';

class PinballFlipper extends BodyComponent<PinballGame> {
  static const double length = 7.2;
  static const double halfHeight = 0.62;
  static const double restAngle = 0.22;
  static const double travelAngle = 0.78;

  final bool isLeft;
  final Vector2 pivot;
  final void Function()? onPressSound;
  late RevoluteJoint _joint;
  late Body _anchorBody;

  PinballFlipper({
    required this.isLeft,
    required Vector2 pivot,
    this.onPressSound,
  }) : pivot = pivot.clone(),
       super(
         renderBody: false,
         fixtureDefs: [
           FixtureDef(
             PolygonShape()..setAsBox(
               length / 2,
               halfHeight,
               Vector2(isLeft ? length / 2 : -length / 2, 0),
               0,
             ),
             density: 1.8,
             friction: 0.24,
             restitution: 0.35,
           ),
         ],
         bodyDef: BodyDef(
           type: BodyType.dynamic,
           position: pivot,
           angle: isLeft ? -restAngle : restAngle,
           angularDamping: 8,
           fixedRotation: false,
         ),
       );

  bool get isPressed => _pressed;
  bool _pressed = false;
  bool _physicsReady = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final spriteName = isLeft
        ? 'sprites/flipper_left.png'
        : 'sprites/flipper_right.png';
    add(
      SpriteComponent(
        sprite: await Sprite.load(spriteName),
        position: Vector2(isLeft ? length / 2 : -length / 2, 0),
        size: Vector2(length + 1.2, 4.2),
        anchor: Anchor.center,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );

    _anchorBody = world.createBody(
      BodyDef(type: BodyType.static, position: pivot.clone()),
    );

    final jointDef = RevoluteJointDef<Body, Body>()
      ..initialize(_anchorBody, body, pivot.clone())
      ..enableLimit = true
      ..lowerAngle = isLeft ? -travelAngle : -0.04
      ..upperAngle = isLeft ? 0.04 : travelAngle
      ..enableMotor = true
      ..motorSpeed = 0
      ..maxMotorTorque = 280;

    _joint = RevoluteJoint(jointDef);
    world.createJoint(_joint);
    _physicsReady = true;
    setPressed(_pressed);
  }

  void setPressed(bool pressed) {
    final changed = _pressed != pressed;
    _pressed = pressed;
    if (changed && pressed) {
      onPressSound?.call();
    }
    if (!_physicsReady) {
      return;
    }

    if (!_joint.motorEnabled) {
      _joint.enableMotor(true);
    }

    final direction = isLeft ? -1 : 1;
    _joint.motorSpeed = pressed ? direction * 18 : direction * -11;
  }

  @override
  void render(Canvas canvas) {}
}

class FlipperControlZone extends PositionComponent with TapCallbacks {
  final PinballFlipper flipper;

  FlipperControlZone({required this.flipper, required bool isLeft})
    : super(
        position: Vector2(isLeft ? 0 : PinballGame.worldWidth / 2, 48),
        size: Vector2(
          isLeft
              ? PinballGame.worldWidth / 2
              : PinballGame.worldWidth / 2 - 5.2,
          16,
        ),
        priority: 100,
      );

  void press() => flipper.setPressed(true);

  void release() => flipper.setPressed(false);

  @override
  void onTapDown(TapDownEvent event) {
    press();
    event.handled = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    release();
    event.handled = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    release();
    event.handled = true;
  }
}
