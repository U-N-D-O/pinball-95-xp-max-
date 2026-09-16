import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'tennis_ball.dart';

class LauncherControl extends PositionComponent with TapCallbacks {
  final TennisBall ball;
  final bool Function() canLaunch;
  final void Function()? onLaunchSound;
  final void Function()? onLaunchHaptic;
  double _flashTimer = 0;

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
          srcSize: Vector2(106, 512),
        ),
        size: size.clone(),
        anchor: Anchor.topLeft,
        paint: Paint()..filterQuality = FilterQuality.none,
      ),
    );
  }

  void launch() {
    if (canLaunch() && ball.isReadyToLaunch) {
      ball.launch();
      _flashTimer = 0.28;
      onLaunchSound?.call();
      onLaunchHaptic?.call();
    }
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
  void onTapDown(TapDownEvent event) {
    launch();
    event.handled = true;
  }
}
