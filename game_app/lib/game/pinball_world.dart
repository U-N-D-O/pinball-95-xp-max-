import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'bumper.dart';
import 'bone_ramp.dart';
import 'chew_toy.dart';
import 'doghouse_lane.dart';
import 'drain_zone.dart';
import 'flipper.dart';
import 'hydrant_spinner.dart';
import 'launcher.dart';
import 'score_hud.dart';
import 'scoring_target.dart';
import 'slingshot.dart';
import 'table_boundaries.dart';
import 'tennis_ball.dart';
import 'table_decorations.dart';
import 'water_bowl.dart';
import 'playfield_component.dart';
import 'pinball_audio.dart';
import 'pinball_telemetry.dart';
import 'pinball_haptics.dart';

enum PinballAchievement { score1000, pawPack, waterSave }

class PinballWorld extends Forge2DWorld {
  static const int startingBalls = 3;

  final PinballAudio audio;
  final PinballTelemetry telemetry;
  final PinballHaptics haptics;
  final void Function(int score)? onHighScore;
  void Function({double duration, double intensity})? onCameraShake;

  PinballWorld({
    PinballAudio? audio,
    this.highScore = 0,
    this.onHighScore,
    this.onCameraShake,
    PinballTelemetry? telemetry,
    PinballHaptics? haptics,
  }) : audio = audio ?? PinballAudio(),
       telemetry = telemetry ?? PinballTelemetry(),
       haptics = haptics ?? PinballHaptics();

  late final PinballFlipper leftFlipper;
  late final PinballFlipper rightFlipper;
  late final FlipperControlZone leftFlipperControl;
  late final FlipperControlZone rightFlipperControl;
  late final TennisBall ball;
  late final LauncherControl launcher;
  int score = 0;
  int highScore;
  bool newHighScore = false;
  int ballsRemaining = startingBalls;
  int pawMissionProgress = 0;
  bool gameOver = false;
  bool doghouseReady = false;
  bool waterBonusActive = false;
  double waterBonusTime = 0;
  final Set<PinballAchievement> achievements = <PinballAchievement>{};
  String? achievementMessage;
  double achievementTime = 0;
  bool _drainQueued = false;
  bool _worldLoaded = false;

  @override
  Future<void> onLoad() async {
    leftFlipper = PinballFlipper(
      isLeft: true,
      pivot: Vector2(8.0, 58.0),
      onPressSound: () {
        audio.play(PinballSound.flipper);
        haptics.light();
      },
    );
    rightFlipper = PinballFlipper(
      isLeft: false,
      pivot: Vector2(28.0, 58.0),
      onPressSound: () {
        audio.play(PinballSound.flipper);
        haptics.light();
      },
    );
    ball = TennisBall(initialPosition: TennisBall.launcherPosition);
    launcher = LauncherControl(
      ball: ball,
      canLaunch: () => !gameOver,
      onLaunchSound: () => audio.play(PinballSound.launch),
      onLaunchHaptic: haptics.medium,
    );

    add(PlayfieldComponent());
    add(TableDecorations());
    add(TableBoundaries());
    add(DoghouseLane(this));
    _addBoneRamp(
      id: 'ramp_a_bone_lane',
      start: Vector2(4.5, 45.0),
      end: Vector2(7.0, 12.5),
      accentColor: const Color(0xFFD4473F),
    );
    add(
      HydrantSpinner(
        position: Vector2(25.5, 30.0),
        onScored: addScore,
        onHitSound: () {
          audio.play(PinballSound.hydrant);
          haptics.medium();
          _shake(intensity: 0.1);
        },
      ),
    );
    add(
      WaterBowl(position: Vector2(26.0, 44.0), onActivated: activateWaterBonus),
    );
    add(
      ChewToy(
        position: Vector2(9.0, 43.0),
        type: ChewToyType.redBall,
        onScored: addScore,
        onHitSound: () {
          audio.play(PinballSound.chewToy);
          _shake(intensity: 0.06);
        },
      ),
    );
    add(
      ChewToy(
        position: Vector2(15.0, 39.5),
        type: ChewToyType.blueBone,
        onScored: addScore,
        onHitSound: () {
          audio.play(PinballSound.chewToy);
          _shake(intensity: 0.06);
        },
      ),
    );
    add(
      ChewToy(
        position: Vector2(21.0, 45.5),
        type: ChewToyType.rope,
        onScored: addScore,
        onHitSound: () {
          audio.play(PinballSound.chewToy);
          _shake(intensity: 0.06);
        },
      ),
    );
    _addBoneRamp(
      id: 'ramp_b_return_lane',
      start: Vector2(22.5, 12.5),
      end: Vector2(27.8, 45.0),
      accentColor: const Color(0xFF317BD0),
    );
    add(ball);
    add(leftFlipper);
    add(rightFlipper);
    leftFlipperControl = FlipperControlZone(flipper: leftFlipper, isLeft: true);
    rightFlipperControl = FlipperControlZone(
      flipper: rightFlipper,
      isLeft: false,
    );
    add(leftFlipperControl);
    add(rightFlipperControl);
    add(launcher);
    _addBumper(position: Vector2(10.5, 17.5), color: BumperColor.red);
    _addBumper(position: Vector2(21.5, 17.5), color: BumperColor.red);
    _addBumper(position: Vector2(16.0, 25.5), color: BumperColor.blue);
    _addBumper(position: Vector2(10.5, 29.0), color: BumperColor.blue);
    _addBumper(position: Vector2(21.5, 29.0), color: BumperColor.blue);
    _addSlingshot(position: Vector2(8.5, 54.0), isLeft: true);
    _addSlingshot(position: Vector2(27.5, 54.0), isLeft: false);
    for (final x in [8.8, 16.0, 23.2]) {
      add(
        ScoringTarget(
          position: Vector2(x, 33.9),
          onScored: addScore,
          onHitSound: () {
            audio.play(PinballSound.target);
            _shake(intensity: 0.08);
          },
        ),
      );
    }
    for (var index = 0; index < 3; index++) {
      add(
        PawMissionTarget(
          index: index,
          position: Vector2(10.0 + (index * 6.0), 11.5),
          onHit: hitPawMissionTarget,
        ),
      );
    }
    add(DoghouseBonusSensor(onBonus: claimDoghouseBonus));
    add(
      DrainZone(
        onBallDrained: (_) {
          queueBallDrain();
        },
      ),
    );
    add(ScoreHud(this));
    _worldLoaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (waterBonusActive) {
      waterBonusTime -= dt;
      if (waterBonusTime <= 0) {
        waterBonusTime = 0;
        waterBonusActive = false;
      }
    }
    if (achievementTime > 0) {
      achievementTime -= dt;
      if (achievementTime <= 0) {
        achievementTime = 0;
        achievementMessage = null;
      }
    }
    if (_drainQueued) {
      resolveQueuedDrain();
    }
  }

  void queueBallDrain() {
    if (!_drainQueued) {
      _drainQueued = true;
      audio.play(PinballSound.drain);
      haptics.heavy();
      telemetry.record('ball_drained');
    }
  }

  void resolveQueuedDrain({void Function()? parkBall}) {
    if (!_drainQueued) {
      return;
    }

    _drainQueued = false;
    if (parkBall != null) {
      parkBall();
    } else {
      ball.parkAtLauncher();
    }

    if (waterBonusActive) {
      waterBonusActive = false;
      waterBonusTime = 0;
    } else {
      ballsRemaining--;
      if (ballsRemaining <= 0 && !gameOver) {
        gameOver = true;
        audio.play(PinballSound.gameOver);
        _shake(duration: 0.22, intensity: 0.28);
      }
    }
  }

  void addScore(int points) {
    if (!gameOver) {
      score += points;
      telemetry.record('score_awarded', value: points);
      if (score > highScore) {
        highScore = score;
        newHighScore = true;
        onHighScore?.call(highScore);
      }
      if (score >= 1000) {
        unlockAchievement(PinballAchievement.score1000, 'SCORE 1000');
      }
    }
  }

  void hitPawMissionTarget(int index) {
    if (gameOver) {
      return;
    }

    if (index == pawMissionProgress) {
      pawMissionProgress++;
      addScore(500);
      audio.play(PinballSound.pawMission);
      telemetry.record('paw_mission_hit');
      _shake(intensity: 0.08);
      if (pawMissionProgress == 3) {
        doghouseReady = true;
        unlockAchievement(PinballAchievement.pawPack, 'PAW PACK');
      }
    } else {
      pawMissionProgress = 0;
      addScore(50);
    }
  }

  void claimDoghouseBonus() {
    if (gameOver || !doghouseReady) {
      return;
    }

    doghouseReady = false;
    pawMissionProgress = 0;
    addScore(1000);
    audio.play(PinballSound.doghouseBonus);
    haptics.heavy();
    telemetry.record('doghouse_bonus');
    _shake(duration: 0.18, intensity: 0.25);
  }

  void activateWaterBonus() {
    if (gameOver) {
      return;
    }

    waterBonusActive = true;
    waterBonusTime = 8;
    addScore(500);
    audio.play(PinballSound.waterBonus);
    haptics.medium();
    telemetry.record('water_bonus');
    _shake(duration: 0.16, intensity: 0.2);
    unlockAchievement(PinballAchievement.waterSave, 'WATER SAVE');
  }

  void restartGame() {
    score = 0;
    newHighScore = false;
    ballsRemaining = startingBalls;
    gameOver = false;
    pawMissionProgress = 0;
    doghouseReady = false;
    waterBonusActive = false;
    waterBonusTime = 0;
    _drainQueued = false;
    achievements.clear();
    achievementMessage = null;
    achievementTime = 0;
    audio.play(PinballSound.restart);
    telemetry.record('game_restart');
    if (_worldLoaded) {
      ball.parkAtLauncher();
    }
  }

  void releaseFlippers() {
    if (!_worldLoaded) {
      return;
    }
    leftFlipperControl.cancelActivePointers();
    rightFlipperControl.cancelActivePointers();
    leftFlipper.setPressed(false);
    rightFlipper.setPressed(false);
  }

  void _addBumper({required Vector2 position, required BumperColor color}) {
    add(
      Bumper(
        position: position,
        color: color,
        onScored: addScore,
        onHitSound: () {
          audio.play(PinballSound.bumper);
          haptics.medium();
          _shake(intensity: 0.16);
        },
      ),
    );
  }

  void _addSlingshot({required Vector2 position, required bool isLeft}) {
    add(
      PinballSlingshot(
        position: position,
        isLeft: isLeft,
        onScored: addScore,
        onHitSound: () {
          audio.play(PinballSound.bumper);
          haptics.medium();
          _shake(intensity: 0.1);
        },
      ),
    );
  }

  void _addBoneRamp({
    required String id,
    required Vector2 start,
    required Vector2 end,
    required Color accentColor,
  }) {
    final ramp = BoneRamp(
      id: id,
      start: start,
      end: end,
      accentColor: accentColor,
      onCompleted: _onRampCompleted,
      onTimedOut: (ramp, ball) {
        telemetry.record('ramp_timeout');
      },
    );
    add(ramp);
    add(BoneRampSensor(ramp: ramp, position: start, isEntry: true));
    add(BoneRampSensor(ramp: ramp, position: end, isEntry: false));
  }

  void _onRampCompleted(BoneRamp ramp, TennisBall ball) {
    addScore(ramp.scoreValue);
    audio.play(PinballSound.target);
    haptics.medium();
    telemetry.record('ramp_completed', value: ramp.scoreValue);
    _shake(intensity: 0.13);
  }

  void unlockAchievement(PinballAchievement achievement, String message) {
    if (achievements.add(achievement)) {
      achievementMessage = message;
      achievementTime = 2.0;
      telemetry.record('achievement_unlocked');
    }
  }

  void _shake({double duration = 0.12, double intensity = 0.12}) {
    onCameraShake?.call(duration: duration, intensity: intensity);
  }
}
