import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'table_tuning.dart';
import 'tennis_ball.dart';

enum BoneRampRouteType { physicalChannel }

/// A reusable sloped ramp contract.
///
/// The ramp is intentionally built from two physical guide rails. The bone
/// sprite remains decorative, while the rails keep collision geometry honest
/// and leave a real channel for the ball to travel through.
class BoneRamp extends BodyComponent<PinballGame> {
  static const double railThickness = 0.28;
  static const double channelWidth = 2.25;
  static const double sensorRadius = 1.3;

  final String id;
  final Vector2 start;
  final Vector2 end;
  final double width;
  final Color accentColor;
  final BoneRampRouteType routeType;
  final bool isBidirectional;
  final int scoreValue;
  final void Function(BoneRamp ramp, TennisBall ball)? onCompleted;
  final void Function(BoneRamp ramp, TennisBall ball)? onTimedOut;
  late final double length;

  final Set<TennisBall> _occupiedBalls = <TennisBall>{};
  final Map<TennisBall, double> _traversalTimers = <TennisBall, double>{};
  double _flashTimer = 0;

  BoneRamp({
    required this.id,
    required Vector2 start,
    required Vector2 end,
    this.width = 0.72,
    this.accentColor = const Color(0xFFD4473F),
    this.routeType = BoneRampRouteType.physicalChannel,
    this.isBidirectional = false,
    this.scoreValue = 500,
    this.onCompleted,
    this.onTimedOut,
  }) : start = start.clone(),
       end = end.clone(),
       super(renderBody: false) {
    length = (end - this.start).length;
  }

  @override
  Vector2 get center => Vector2((start.x + end.x) / 2, (start.y + end.y) / 2);

  double get rampAngle => math.atan2(end.y - start.y, end.x - start.x);

  Vector2 get travelDirection {
    final direction = end - start;
    if (direction.length2 <= 0.000001) {
      return Vector2(1, 0);
    }
    return direction.normalized();
  }

  double get railOffset => channelWidth / 2 + railThickness / 2;

  int get occupancy => _occupiedBalls.length;

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: center, angle: rampAngle),
    );
    body.userData = this;

    for (final offset in [-railOffset, railOffset]) {
      final shape = PolygonShape()
        ..setAsBox(length / 2, railThickness / 2, Vector2(0, offset), 0);
      body.createFixture(
        FixtureDef(
          shape,
          friction: 0.22,
          restitution: TableTuning.railRestitution,
        ),
      );
    }

    return body;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      SpriteComponent(
        sprite: await Sprite.load('sprites/bone_ramp.png'),
        size: Vector2(length + width * 1.8, width * 1.8),
        anchor: Anchor.center,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer = math.max(0, _flashTimer - dt);
    }

    if (_traversalTimers.isEmpty) {
      return;
    }

    final timedOut = <TennisBall>[];
    for (final entry in _traversalTimers.entries) {
      final remaining = entry.value - dt;
      if (remaining <= 0) {
        timedOut.add(entry.key);
      } else {
        _traversalTimers[entry.key] = remaining;
      }
    }

    for (final ball in timedOut) {
      _occupiedBalls.remove(ball);
      _traversalTimers.remove(ball);
      onTimedOut?.call(this, ball);
    }
  }

  /// Captures one ball when it reaches this ramp's designated entrance.
  ///
  /// A missed entrance has no special effect: the ball remains under normal
  /// table physics and can try the shot again. A second ball is ignored until
  /// the current traversal exits or times out.
  void registerEntry(TennisBall ball) {
    if (_occupiedBalls.isNotEmpty || _occupiedBalls.contains(ball)) {
      return;
    }

    _occupiedBalls.add(ball);
    _traversalTimers[ball] = TableTuning.rampTraversalTimeout;
    _flashTimer = 0.18;
  }

  /// Completes and scores a traversal only if that ball entered this ramp.
  void registerExit(TennisBall ball) {
    if (!_occupiedBalls.remove(ball)) {
      return;
    }

    _traversalTimers.remove(ball);
    _flashTimer = 0.3;

    final velocity = ball.body.linearVelocity.clone();
    final speedAlongRamp = velocity.dot(travelDirection);
    if (speedAlongRamp < TableTuning.rampMinimumExitSpeed) {
      velocity +=
          travelDirection * (TableTuning.rampMinimumExitSpeed - speedAlongRamp);
      ball.body.linearVelocity = TennisBall.capVelocity(velocity);
      ball.body.setAwake(true);
    }

    onCompleted?.call(this, ball);
  }

  @override
  void render(Canvas canvas) {
    final railPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..isAntiAlias = false;

    canvas.drawLine(
      Offset(-length / 2, -railOffset),
      Offset(length / 2, -railOffset),
      railPaint,
    );
    canvas.drawLine(
      Offset(-length / 2, railOffset),
      Offset(length / 2, railOffset),
      railPaint,
    );

    if (_flashTimer > 0) {
      final flashPaint = Paint()
        ..color = const Color(0xFFFFF1A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2
        ..isAntiAlias = false;
      canvas.drawLine(
        Offset(-length / 2, -railOffset),
        Offset(length / 2, -railOffset),
        flashPaint,
      );
      canvas.drawLine(
        Offset(-length / 2, railOffset),
        Offset(length / 2, railOffset),
        flashPaint,
      );
    }
  }
}

/// Sensor pair for the ramp's one-way entry and exit contract.
class BoneRampSensor extends BodyComponent<PinballGame> with ContactCallbacks {
  final BoneRamp ramp;
  final bool isEntry;
  @override
  final Vector2 position;

  BoneRampSensor({
    required this.ramp,
    required Vector2 position,
    required this.isEntry,
  }) : position = position.clone(),
       super(renderBody: false);

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: position, userData: this),
    );
    body.createFixture(
      FixtureDef(CircleShape()..radius = BoneRamp.sensorRadius, isSensor: true),
    );
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! TennisBall) {
      return;
    }

    if (isEntry) {
      ramp.registerEntry(other);
    } else {
      ramp.registerExit(other);
    }
  }
}
