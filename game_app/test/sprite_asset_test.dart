import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const spriteAssets = [
    'assets/images/sprites/ball_tennis_idle.png',
    'assets/images/sprites/bumper_red.png',
    'assets/images/sprites/bumper_blue.png',
    'assets/images/sprites/doghouse_lane.png',
    'assets/images/sprites/paw_mission_target.png',
    'assets/images/sprites/chew_toy_red_ball.png',
    'assets/images/sprites/chew_toy_blue_bone.png',
    'assets/images/sprites/chew_toy_rope.png',
    'assets/images/sprites/hydrant_spinner.png',
    'assets/images/sprites/water_bowl.png',
    'assets/images/sprites/bone_ramp.png',
    'assets/images/sprites/launcher_lane.png',
    'assets/images/sprites/flipper_left.png',
    'assets/images/sprites/flipper_right.png',
    'assets/images/sprites/grass_flower_cluster.png',
    'assets/images/sprites/rock_decoration.png',
    'assets/images/sprites/paw_decoration.png',
  ];

  test('every registered sprite asset loads', () async {
    var totalPixels = 0;
    for (final assetPath in spriteAssets) {
      final data = await rootBundle.load(assetPath);
      expect(
        data.lengthInBytes,
        greaterThan(0),
        reason: 'Sprite asset is missing or empty: $assetPath',
      );
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      totalPixels += image.width * image.height;
      expect(image.width, lessThanOrEqualTo(512), reason: assetPath);
      expect(image.height, lessThanOrEqualTo(512), reason: assetPath);
      image.dispose();
      codec.dispose();
    }
    expect(totalPixels, lessThanOrEqualTo(5000000));
  });
}
