import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';

import 'pinball_world.dart';
import 'pinball_audio.dart';
import 'table_tuning.dart';
import 'camera_shake.dart';
import 'pinball_telemetry.dart';
import 'pinball_haptics.dart';

class PinballGame extends Forge2DGame<PinballWorld>
    with HasKeyboardHandlerComponents<PinballWorld> {
  static const double gameWidth = 360;
  static const double gameHeight = 640;
  static const double physicsPixelsPerUnit = 10;
  static const double worldWidth = gameWidth / physicsPixelsPerUnit;
  static const double worldHeight = gameHeight / physicsPixelsPerUnit;
  late final CameraShakeController cameraShake;
  final PinballPerformance performance = PinballPerformance();

  PinballGame({
    PinballAudio? audio,
    int highScore = 0,
    void Function(int score)? onHighScore,
    PinballTelemetry? telemetry,
    PinballHaptics? haptics,
  }) : super(
         world: PinballWorld(
           audio: audio ?? PinballAudio(enablePlayback: true),
           highScore: highScore,
           onHighScore: onHighScore,
           telemetry: telemetry,
           haptics: haptics,
         ),
         gravity: Vector2(0, TableTuning.gravity),
         camera: CameraComponent.withFixedResolution(
           width: gameWidth,
           height: gameHeight,
           viewfinder: Viewfinder()
             ..position = Vector2(worldWidth / 2, worldHeight / 2),
         ),
       ) {
    cameraShake = CameraShakeController(camera: camera);
    world.onCameraShake = ({duration = 0.12, intensity = 0.12}) {
      cameraShake.trigger(duration: duration, intensity: intensity);
    };
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(cameraShake);

    add(
      KeyboardListenerComponent(
        keyDown: {
          LogicalKeyboardKey.keyZ: (_) {
            world.leftFlipper.setPressed(true);
            return true;
          },
          LogicalKeyboardKey.slash: (_) {
            world.rightFlipper.setPressed(true);
            return true;
          },
          LogicalKeyboardKey.arrowLeft: (_) {
            world.leftFlipper.setPressed(true);
            return true;
          },
          LogicalKeyboardKey.arrowRight: (_) {
            world.rightFlipper.setPressed(true);
            return true;
          },
          LogicalKeyboardKey.space: (_) {
            world.launcher.launch();
            return true;
          },
          LogicalKeyboardKey.enter: (_) {
            world.launcher.launch();
            return true;
          },
          LogicalKeyboardKey.keyR: (_) {
            world.restartGame();
            return true;
          },
          LogicalKeyboardKey.keyP: (_) {
            togglePause();
            return true;
          },
        },
        keyUp: {
          LogicalKeyboardKey.keyZ: (_) {
            world.leftFlipper.setPressed(false);
            return true;
          },
          LogicalKeyboardKey.slash: (_) {
            world.rightFlipper.setPressed(false);
            return true;
          },
          LogicalKeyboardKey.arrowLeft: (_) {
            world.leftFlipper.setPressed(false);
            return true;
          },
          LogicalKeyboardKey.arrowRight: (_) {
            world.rightFlipper.setPressed(false);
            return true;
          },
          LogicalKeyboardKey.space: (_) => true,
          LogicalKeyboardKey.enter: (_) => true,
          LogicalKeyboardKey.keyR: (_) => true,
          LogicalKeyboardKey.keyP: (_) => true,
        },
      ),
    );
  }

  @override
  void update(double dt) {
    performance.sample(dt);
    super.update(dt);
  }

  void pauseGame() {
    world.releaseFlippers();
    pauseEngine();
  }

  void resumeGame() {
    resumeEngine();
  }

  void togglePause() {
    if (paused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF07101C);
}
