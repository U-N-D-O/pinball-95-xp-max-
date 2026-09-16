import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/score_hud.dart';
import 'package:pinball_neo_95/game/pinball_world.dart';

void main() {
  test('new world starts with a clean playable state', () {
    final world = PinballWorld();

    expect(world.score, 0);
    expect(world.ballsRemaining, PinballWorld.startingBalls);
    expect(world.pawMissionProgress, 0);
    expect(world.gameOver, isFalse);
    expect(world.doghouseReady, isFalse);
    expect(world.waterBonusActive, isFalse);
  });

  test('paw mission awards progress and doghouse bonus', () {
    final world = PinballWorld();

    world.hitPawMissionTarget(0);
    world.hitPawMissionTarget(1);
    world.hitPawMissionTarget(2);

    expect(world.score, 1500);
    expect(world.pawMissionProgress, 3);
    expect(world.doghouseReady, isTrue);

    world.claimDoghouseBonus();

    expect(world.score, 2500);
    expect(world.pawMissionProgress, 0);
    expect(world.doghouseReady, isFalse);
  });

  test('wrong paw order resets progress with a small score', () {
    final world = PinballWorld();

    world.hitPawMissionTarget(0);
    world.hitPawMissionTarget(2);

    expect(world.score, 550);
    expect(world.pawMissionProgress, 0);
    expect(world.doghouseReady, isFalse);
  });

  test('water bonus activates and gameplay is gated after game over', () {
    final world = PinballWorld();

    world.activateWaterBonus();
    world.addScore(250);

    expect(world.waterBonusActive, isTrue);
    expect(world.waterBonusTime, 8);
    expect(world.score, 750);

    world.gameOver = true;
    world.addScore(1000);
    world.hitPawMissionTarget(0);
    world.activateWaterBonus();

    expect(world.score, 750);
    expect(world.pawMissionProgress, 0);
    expect(world.waterBonusTime, 8);
  });

  test('drain consumes water save before consuming a ball', () {
    final world = PinballWorld();
    var parkedBalls = 0;

    world.activateWaterBonus();
    world.queueBallDrain();
    world.resolveQueuedDrain(parkBall: () => parkedBalls++);

    expect(parkedBalls, 1);
    expect(world.ballsRemaining, PinballWorld.startingBalls);
    expect(world.waterBonusActive, isFalse);

    world.queueBallDrain();
    world.resolveQueuedDrain(parkBall: () => parkedBalls++);

    expect(parkedBalls, 2);
    expect(world.ballsRemaining, PinballWorld.startingBalls - 1);
  });

  test('three unprotected drains end the game', () {
    final world = PinballWorld();

    for (var drain = 0; drain < PinballWorld.startingBalls; drain++) {
      world.queueBallDrain();
      world.resolveQueuedDrain(parkBall: () {});
    }

    expect(world.ballsRemaining, 0);
    expect(world.gameOver, isTrue);
  });

  test('game-over HUD touch restart resets the session safely', () {
    final world = PinballWorld()
      ..score = 2500
      ..ballsRemaining = 0
      ..gameOver = true
      ..pawMissionProgress = 3
      ..doghouseReady = true
      ..newHighScore = true;
    final hud = ScoreHud(world);

    hud.restartFromTouch();

    expect(world.score, 0);
    expect(world.ballsRemaining, PinballWorld.startingBalls);
    expect(world.gameOver, isFalse);
    expect(world.pawMissionProgress, 0);
    expect(world.doghouseReady, isFalse);
    expect(world.newHighScore, isFalse);
  });

  test(
    'new high-score state is raised during a run and cleared on restart',
    () {
      final world = PinballWorld(highScore: 100);

      world.addScore(101);
      expect(world.highScore, 101);
      expect(world.newHighScore, isTrue);

      world.restartGame();
      expect(world.newHighScore, isFalse);
    },
  );

  test('achievement milestones unlock once and reset with a new game', () {
    final world = PinballWorld();

    world.addScore(1000);
    world.addScore(1);
    expect(world.achievements, contains(PinballAchievement.score1000));
    expect(world.achievementMessage, 'SCORE 1000');

    world.hitPawMissionTarget(0);
    world.hitPawMissionTarget(1);
    world.hitPawMissionTarget(2);
    expect(world.achievements, contains(PinballAchievement.pawPack));
    expect(world.achievementMessage, 'PAW PACK');

    world.activateWaterBonus();
    expect(world.achievements, contains(PinballAchievement.waterSave));
    expect(world.achievements.length, 3);

    world.restartGame();
    expect(world.achievements, isEmpty);
    expect(world.achievementMessage, isNull);
  });
}
