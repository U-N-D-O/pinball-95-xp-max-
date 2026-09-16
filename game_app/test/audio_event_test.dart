import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/pinball_audio.dart';
import 'package:pinball_neo_95/game/pinball_world.dart';

void main() {
  test('audio bus records events and respects mute state', () {
    final audio = PinballAudio();

    audio.setVolume(1.5);
    expect(audio.volume, 1.0);
    audio.setVolume(-0.5);
    expect(audio.volume, 0.0);
    audio.setVolume(0.8);

    audio.play(PinballSound.bumper);
    audio.muted = true;
    audio.play(PinballSound.launch);

    expect(audio.events, [PinballSound.bumper]);
    expect(audio.lastEvent, PinballSound.bumper);

    audio.muted = false;
    audio.play(PinballSound.launch);
    expect(audio.events, [PinballSound.bumper, PinballSound.launch]);

    audio.clear();
    expect(audio.events, isEmpty);
    expect(audio.lastEvent, isNull);
  });

  test('audio preload is inert when playback is disabled', () async {
    final audio = PinballAudio();

    await audio.preload();

    expect(audio.isPreloaded, isFalse);
  });

  test('world emits validated mission and bonus sound events', () {
    final world = PinballWorld();

    world.hitPawMissionTarget(0);
    world.hitPawMissionTarget(1);
    world.hitPawMissionTarget(2);
    world.claimDoghouseBonus();
    world.activateWaterBonus();

    expect(world.audio.events, [
      PinballSound.pawMission,
      PinballSound.pawMission,
      PinballSound.pawMission,
      PinballSound.doghouseBonus,
      PinballSound.waterBonus,
    ]);
  });

  test('world emits drain and game-over events in order', () {
    final world = PinballWorld();

    for (var drain = 0; drain < PinballWorld.startingBalls; drain++) {
      world.queueBallDrain();
      world.resolveQueuedDrain(parkBall: () {});
    }

    expect(world.ballsRemaining, 0);
    expect(world.gameOver, isTrue);
    expect(world.audio.events, [
      PinballSound.drain,
      PinballSound.drain,
      PinballSound.drain,
      PinballSound.gameOver,
    ]);

    world.restartGame();
    expect(world.audio.lastEvent, PinballSound.restart);
  });
}
