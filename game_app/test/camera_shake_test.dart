import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/camera_shake.dart';
import 'package:pinball_neo_95/game/pinball_world.dart';

void main() {
  test('camera shake is capped and returns to its rest position', () {
    final camera = CameraComponent.withFixedResolution(
      width: 360,
      height: 640,
      viewfinder: Viewfinder()..position = Vector2(18, 32),
    );
    final shake = CameraShakeController(camera: camera);

    shake.trigger(duration: 0.2, intensity: 2.0);
    expect(shake.isShaking, isTrue);
    expect(shake.intensity, CameraShakeController.maxIntensity);

    shake.update(0.1);
    expect(shake.isShaking, isTrue);
    shake.update(0.2);
    expect(shake.isShaking, isFalse);
    expect(camera.viewfinder.position, Vector2(18, 32));
  });

  test('world sends bonus feedback through its optional camera callback', () {
    var recordedDuration = 0.0;
    var recordedIntensity = 0.0;
    final world = PinballWorld(
      onCameraShake: ({double duration = 0.12, double intensity = 0.12}) {
        recordedDuration = duration;
        recordedIntensity = intensity;
      },
    );

    world.activateWaterBonus();

    expect(recordedDuration, 0.16);
    expect(recordedIntensity, 0.2);
  });
}
