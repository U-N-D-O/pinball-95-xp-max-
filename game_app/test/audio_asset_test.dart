import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const soundAssets = [
    'assets/audio/sfx/flipper.wav',
    'assets/audio/sfx/launch.wav',
    'assets/audio/sfx/bumper.wav',
    'assets/audio/sfx/target.wav',
    'assets/audio/sfx/chew_toy.wav',
    'assets/audio/sfx/paw_mission.wav',
    'assets/audio/sfx/doghouse_bonus.wav',
    'assets/audio/sfx/hydrant.wav',
    'assets/audio/sfx/water_bonus.wav',
    'assets/audio/sfx/drain.wav',
    'assets/audio/sfx/game_over.wav',
    'assets/audio/sfx/restart.wav',
  ];

  test('every registered sound asset loads', () async {
    for (final assetPath in soundAssets) {
      final data = await rootBundle.load(assetPath);
      final header = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      expect(
        data.lengthInBytes,
        greaterThan(44),
        reason: 'Sound asset is missing or empty: $assetPath',
      );
      expect(String.fromCharCodes(header.take(4)), 'RIFF');
      expect(String.fromCharCodes(header.skip(8).take(4)), 'WAVE');
      expect(header[34], 8, reason: 'Cue must remain 8-bit PCM: $assetPath');
    }
  });
}
