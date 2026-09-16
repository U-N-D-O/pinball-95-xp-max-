import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/pinball_world.dart';
import 'package:pinball_neo_95/pinball_persistence.dart';

class MemorySaveStore implements SaveStore {
  final Map<String, Object> values = {};

  @override
  Object? read(String key) => values[key];

  @override
  Future<void> write(String key, Object value) async {
    values[key] = value;
  }
}

void main() {
  test('profile saves and loads high score and audio settings', () async {
    final store = MemorySaveStore();
    final persistence = PinballPersistence(store);

    await persistence.saveHighScore(9876);
    await persistence.saveAudioSettings(
      muted: true,
      volume: 0.35,
      hapticsEnabled: false,
    );
    final profile = await persistence.load();

    expect(profile.highScore, 9876);
    expect(profile.muted, isTrue);
    expect(profile.volume, 0.35);
    expect(profile.hapticsEnabled, isFalse);
  });

  test('profile loading clamps invalid volume values', () async {
    final store = MemorySaveStore()
      ..values['high_score'] = 1200
      ..values['muted'] = false
      ..values['volume'] = 4.0;

    final profile = await PinballPersistence(store).load();

    expect(profile.highScore, 1200);
    expect(profile.volume, 1.0);
  });

  test('world reports only new high scores', () {
    final scores = <int>[];
    final world = PinballWorld(highScore: 100, onHighScore: scores.add);

    world.addScore(50);
    world.addScore(75);

    expect(world.score, 125);
    expect(world.highScore, 125);
    expect(scores, [125]);
  });
}
