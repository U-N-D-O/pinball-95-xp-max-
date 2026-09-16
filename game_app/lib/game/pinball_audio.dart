import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

enum PinballSound {
  flipper,
  launch,
  bumper,
  target,
  chewToy,
  pawMission,
  doghouseBonus,
  hydrant,
  waterBonus,
  drain,
  gameOver,
  restart,
}

/// Deterministic sound-event bus for the game's generated arcade sound cues.
class PinballAudio {
  PinballAudio({this.enablePlayback = false});

  static const Map<PinballSound, String> _files = {
    PinballSound.flipper: 'sfx/flipper.wav',
    PinballSound.launch: 'sfx/launch.wav',
    PinballSound.bumper: 'sfx/bumper.wav',
    PinballSound.target: 'sfx/target.wav',
    PinballSound.chewToy: 'sfx/chew_toy.wav',
    PinballSound.pawMission: 'sfx/paw_mission.wav',
    PinballSound.doghouseBonus: 'sfx/doghouse_bonus.wav',
    PinballSound.hydrant: 'sfx/hydrant.wav',
    PinballSound.waterBonus: 'sfx/water_bonus.wav',
    PinballSound.drain: 'sfx/drain.wav',
    PinballSound.gameOver: 'sfx/game_over.wav',
    PinballSound.restart: 'sfx/restart.wav',
  };

  final List<PinballSound> events = <PinballSound>[];
  final bool enablePlayback;
  bool muted = false;
  double volume = 0.8;
  bool _preloaded = false;

  bool get isPreloaded => _preloaded;

  Future<void> preload() async {
    if (!enablePlayback || _preloaded) {
      return;
    }
    try {
      await FlameAudio.audioCache.loadAll(_files.values.toList());
      _preloaded = true;
    } catch (_) {
      // Preloading is an optimization; lazy playback remains the fallback.
    }
  }

  void setVolume(double value) {
    volume = value.clamp(0.0, 1.0).toDouble();
  }

  void play(PinballSound sound) {
    if (!muted) {
      events.add(sound);
      if (enablePlayback) {
        unawaited(_playAsset(sound));
      }
    }
  }

  PinballSound? get lastEvent => events.isEmpty ? null : events.last;

  void clear() => events.clear();

  Future<void> _playAsset(PinballSound sound) async {
    try {
      await FlameAudio.play(_files[sound]!, volume: volume);
    } catch (_) {
      // A missing platform audio backend must not interrupt gameplay.
    }
  }
}
