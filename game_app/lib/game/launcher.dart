import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'table_tuning.dart';
import 'tennis_ball.dart';

class LauncherControl extends PositionComponent with DragCallbacks {
  final TennisBall ball;
  final bool Function() canLaunch;
  final void Function()? onLaunchSound;
  final void Function()? onLaunchHaptic;
  double _flashTimer = 0;
  double _pullDistance = 0;
  int? _pointerId;
  late SpriteComponent _plungerSprite;

  double get pullDistance => _pullDistance;
  double get pullRatio => _pullDistance / TableTuning.launcherMaxPullDistance;
  bool get isPulling => _pointerId != null;

  LauncherControl({
    required this.ball,
    required this.canLaunch,
    this.onLaunchSound,
    this.onLaunchHaptic,
  }) : super(
         position: Vector2(30.8, 48),
         size: Vector2(5.2, 16),
         priority: 200,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      SpriteComponent(
        sprite: await Sprite.load(
          'sprites/launcher_lane.png',
          srcPosition: Vector2(204, 0),
          srcSize: Vector2(106, 300),
        ),
        size: Vector2(size.x, size.y * 300 / 512),
        anchor: Anchor.topLeft,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );
    _plungerSprite = SpriteComponent(
      sprite: await Sprite.load(
        'sprites/launcher_lane.png',
        srcPosition: Vector2(204, 300),
        srcSize: Vector2(106, 212),
      ),
      position: Vector2(0, size.y * 300 / 512),
      size: Vector2(size.x, size.y * 212 / 512),
      anchor: Anchor.topLeft,
      paint: Paint()..filterQuality = FilterQuality.none,
    );
    add(_plungerSprite);
  }

  void launch({double strength = 1.0}) {
    if (canLaunch() && ball.isReadyToLaunch) {
      ball.launch(strength: strength);
      _flashTimer = 0.28;
      onLaunchSound?.call();
      onLaunchHaptic?.call();
    }
  }

  void beginPull(int pointerId) {
    if (_pointerId != null || !canLaunch() || !ball.isReadyToLaunch) {
      return;
    }
    _pointerId = pointerId;
    _pullDistance = 0;
    _updatePlungerPosition();
  }

  void updatePull(int pointerId, double deltaY) {
    if (_pointerId != pointerId) {
      return;
    }
    _pullDistance = (_pullDistance + deltaY).clamp(
      0.0,
      TableTuning.launcherMaxPullDistance,
    );
    _updatePlungerPosition();
  }

  void endPull(int pointerId, {bool canceled = false}) {
    if (_pointerId != pointerId) {
      return;
    }

    final strength = pullRatio;
    _pointerId = null;
    _pullDistance = 0;
    _updatePlungerPosition();

    if (!canceled && strength >= _minimumPullRatio) {
      launch(strength: strength);
    }
  }

  double get _minimumPullRatio =>
      TableTuning.launcherMinimumPullDistance /
      TableTuning.launcherMaxPullDistance;

  void _updatePlungerPosition() {
    if (!isMounted) {
      return;
    }
    _plungerSprite.position.y = size.y * 300 / 512 + _pullDistance;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    _drawSpringExtension(canvas);
    if (_flashTimer <= 0) {
      return;
    }

    final flash = Paint()
      ..color = const Color(0xFFFFF07D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.18
      ..isAntiAlias = false;
    canvas.drawRect(const Rect.fromLTWH(0.42, 0.25, 4.36, 15.5), flash);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    beginPull(event.pointerId);
    event.handled = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    updatePull(event.pointerId, event.localDelta.y);
    event.handled = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    endPull(event.pointerId);
    event.handled = true;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    endPull(event.pointerId, canceled: true);
    event.handled = true;
  }

  void _drawSpringExtension(Canvas canvas) {
    if (_pullDistance <= 0) {
      return;
    }

    final springTop = size.y * 300 / 512;
    final springPaint = Paint()
      ..color = const Color(0xFF16243A)
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTWH(1.7, springTop, 1.8, _pullDistance + 1.4),
      springPaint,
    );

    final coilPaint = Paint()
      ..color = const Color(0xFFE6E2D0)
      ..strokeWidth = 0.22
      ..isAntiAlias = false;
    for (var y = springTop + 0.45; y < springTop + _pullDistance; y += 0.55) {
      canvas.drawLine(Offset(1.78, y), Offset(3.42, y), coilPaint);
    }
  }
}
