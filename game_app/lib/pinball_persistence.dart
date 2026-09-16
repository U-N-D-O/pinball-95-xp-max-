import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SaveStore {
  Object? read(String key);

  Future<void> write(String key, Object value);
}

class SharedPreferencesStore implements SaveStore {
  final SharedPreferences preferences;

  SharedPreferencesStore(this.preferences);

  @override
  Object? read(String key) => preferences.get(key);

  @override
  Future<void> write(String key, Object value) async {
    switch (value) {
      case final int number:
        await preferences.setInt(key, number);
      case final double number:
        await preferences.setDouble(key, number);
      case final bool enabled:
        await preferences.setBool(key, enabled);
      case final String text:
        await preferences.setString(key, text);
    }
  }
}

class PinballProfile {
  final int highScore;
  final bool muted;
  final double volume;
  final bool hapticsEnabled;

  const PinballProfile({
    this.highScore = 0,
    this.muted = false,
    this.volume = 0.8,
    this.hapticsEnabled = true,
  });
}

class PinballPersistence {
  static const _highScoreKey = 'high_score';
  static const _mutedKey = 'muted';
  static const _volumeKey = 'volume';
  static const _hapticsEnabledKey = 'haptics_enabled';

  final SaveStore store;

  PinballPersistence(this.store);

  static Future<PinballPersistence> fromSharedPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    return PinballPersistence(SharedPreferencesStore(preferences));
  }

  Future<PinballProfile> load() async {
    final highScore = store.read(_highScoreKey);
    final muted = store.read(_mutedKey);
    final volume = store.read(_volumeKey);
    final hapticsEnabled = store.read(_hapticsEnabledKey);
    return PinballProfile(
      highScore: highScore is int ? highScore : 0,
      muted: muted is bool ? muted : false,
      volume: volume is num ? volume.toDouble().clamp(0.0, 1.0) : 0.8,
      hapticsEnabled: hapticsEnabled is bool ? hapticsEnabled : true,
    );
  }

  Future<void> saveHighScore(int score) => store.write(_highScoreKey, score);

  Future<void> saveAudioSettings({
    required bool muted,
    required double volume,
    required bool hapticsEnabled,
  }) async {
    await store.write(_mutedKey, muted);
    await store.write(_volumeKey, volume.clamp(0.0, 1.0).toDouble());
    await store.write(_hapticsEnabledKey, hapticsEnabled);
  }
}
