import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'pinball_world.dart';
import 'tennis_ball.dart';

class DoghouseLane extends PositionComponent {
  final PinballWorld world;

  DoghouseLane(this.world)
    : super(
        position: Vector2(13.0, 9.3),
        size: Vector2(6.0, 5.2),
        priority: 20,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      SpriteComponent(
        sprite: await Sprite.load('sprites/doghouse_lane.png'),
        size: size.clone(),
        anchor: Anchor.topLeft,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );
    add(_DoghouseStatusOverlay(world));
  }
}

class _DoghouseStatusOverlay extends PositionComponent {
  final PinballWorld world;

  _DoghouseStatusOverlay(this.world)
    : super(size: Vector2(6.0, 5.2), priority: 1);

  @override
  void render(Canvas canvas) {
    if (!world.doghouseReady) {
      return;
    }

    final glow = Paint()
      ..color = const Color(0xFFFFF07D)
      ..isAntiAlias = false;
    canvas.drawRect(const Rect.fromLTWH(0.95, 2.35, 0.45, 0.45), glow);
    canvas.drawRect(const Rect.fromLTWH(4.6, 2.35, 0.45, 0.45), glow);
  }
}

class PawMissionTarget extends BodyComponent<PinballGame>
    with ContactCallbacks {
  static const double width = 2.0;
  static const double height = 1.1;

  final int index;
  @override
  final Vector2 position;
  final void Function(int index) onHit;
  final void Function()? onHitSound;
  double _cooldown = 0;
  double _flashTimer = 0;

  PawMissionTarget({
    required this.index,
    required Vector2 position,
    required this.onHit,
    this.onHitSound,
  }) : position = position.clone(),
       super(renderBody: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      SpriteComponent(
        sprite: await Sprite.load('sprites/paw_mission_target.png'),
        size: Vector2.all(width + 0.2),
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

    _cooldown = 0.25;
    _flashTimer = 0.3;
    onHit(index);
    onHitSound?.call();
    return true;
  }

  @override
  void render(Canvas canvas) {
    if (_flashTimer <= 0) {
      return;
    }

    final flash = Paint()
      ..color = const Color(0xFFFFF1A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.18
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTWH(
        -width / 2 - 0.22,
        -height / 2 - 0.22,
        width + 0.44,
        height + 0.44,
      ),
      flash,
    );
  }
}

class DoghouseBonusSensor extends BodyComponent<PinballGame>
    with ContactCallbacks {
  final void Function() onBonus;
  final void Function()? onBonusSound;
  double _cooldown = 0;

  DoghouseBonusSensor({required this.onBonus, this.onBonusSound})
    : super(renderBody: false);

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: Vector2(16, 13.8)),
    );
    body.userData = this;
    final shape = PolygonShape()..setAsBoxXY(2.1, 0.9);
    body.createFixture(FixtureDef(shape, isSensor: true));
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0) {
      _cooldown -= dt;
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is TennisBall && _cooldown <= 0) {
      _cooldown = 0.5;
      onBonus();
      onBonusSound?.call();
    }
  }
}
