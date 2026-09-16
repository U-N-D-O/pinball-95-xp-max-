import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/pinball_audio.dart';
import 'game/pinball_haptics.dart';
import 'game/pinball_game.dart';
import 'pinball_pause.dart';
import 'pinball_persistence.dart';
import 'pinball_settings.dart';
import 'pinball_title.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final persistence = await PinballPersistence.fromSharedPreferences();
  final profile = await persistence.load();
  runApp(PinballApp(profile: profile, persistence: persistence));
}

class PinballApp extends StatefulWidget {
  final PinballProfile profile;
  final PinballPersistence? persistence;

  const PinballApp({
    this.profile = const PinballProfile(),
    this.persistence,
    super.key,
  });

  @override
  State<PinballApp> createState() => _PinballAppState();
}

class _PinballAppState extends State<PinballApp> with WidgetsBindingObserver {
  late final PinballGame game;
  bool _titleOpen = true;
  bool _settingsOpen = false;
  bool _paused = false;
  bool _resumeAfterSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final audio = PinballAudio(enablePlayback: true)
      ..muted = widget.profile.muted
      ..setVolume(widget.profile.volume);
    unawaited(audio.preload());
    final haptics = PinballHaptics(
      enablePlatform: true,
      enabled: widget.profile.hapticsEnabled,
    );
    game = PinballGame(
      audio: audio,
      haptics: haptics,
      highScore: widget.profile.highScore,
      onHighScore: _saveHighScore,
    );
    game.pauseGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.inactive &&
        state != AppLifecycleState.paused &&
        state != AppLifecycleState.detached) {
      return;
    }
    if (game.paused) {
      return;
    }
    game.pauseGame();
    if (mounted) {
      setState(() => _paused = true);
    }
  }

  void _saveHighScore(int score) {
    final persistence = widget.persistence;
    if (persistence != null) {
      unawaited(persistence.saveHighScore(score));
    }
  }

  void _closeSettings() {
    final persistence = widget.persistence;
    if (persistence != null) {
      unawaited(
        persistence.saveAudioSettings(
          muted: game.world.audio.muted,
          volume: game.world.audio.volume,
          hapticsEnabled: game.world.haptics.enabled,
        ),
      );
    }
    final resumeAfterSettings = _resumeAfterSettings;
    _resumeAfterSettings = false;
    setState(() => _settingsOpen = false);
    if (resumeAfterSettings) {
      game.resumeGame();
    }
  }

  void _openSettings() {
    _resumeAfterSettings = !game.paused;
    if (_resumeAfterSettings) {
      game.pauseGame();
    }
    setState(() => _settingsOpen = true);
  }

  void _startGame() {
    game.resumeGame();
    setState(() => _titleOpen = false);
  }

  void _togglePause() {
    if (game.paused) {
      game.resumeGame();
    } else {
      game.pauseGame();
    }
    setState(() => _paused = game.paused);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinball Neo 95',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFF07101C),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              GameWidget(game: game),
              if (!_titleOpen && !_settingsOpen && !_paused)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _togglePause,
                        tooltip: 'Pause game',
                        color: const Color(0xFF7BE2B2),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xCC0C1B29),
                          shape: const RoundedRectangleBorder(),
                        ),
                        icon: const Icon(Icons.pause),
                      ),
                      IconButton(
                        onPressed: _openSettings,
                        tooltip: 'Open settings',
                        color: const Color(0xFFFFC928),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xCC0C1B29),
                          shape: const RoundedRectangleBorder(),
                        ),
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                ),
              if (_settingsOpen)
                PinballSettingsPanel(
                  audio: game.world.audio,
                  haptics: game.world.haptics,
                  onClose: _closeSettings,
                ),
              if (_paused && !_settingsOpen)
                PinballPausePanel(onResume: _togglePause),
              if (_titleOpen)
                PinballTitlePanel(
                  highScore: game.world.highScore,
                  onStart: _startGame,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
