import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/bumper.dart';
import 'package:pinball_neo_95/game/chew_toy.dart';
import 'package:pinball_neo_95/game/doghouse_lane.dart';
import 'package:pinball_neo_95/game/hydrant_spinner.dart';
import 'package:pinball_neo_95/game/scoring_target.dart';
import 'package:pinball_neo_95/game/water_bowl.dart';

void main() {
  test('bumper awards points once during its cooldown', () {
    var score = 0;
    final bumper = Bumper(
      position: Vector2.zero(),
      color: BumperColor.red,
      onScored: (points) => score += points,
    );

    expect(bumper.registerHit(), isTrue);
    expect(bumper.registerHit(), isFalse);
    expect(score, 100);
  });

  test('scoring targets and chew toys award their configured values', () {
    var score = 0;
    final target = ScoringTarget(
      position: Vector2.zero(),
      onScored: (points) => score += points,
    );
    final toy = ChewToy(
      position: Vector2.zero(),
      type: ChewToyType.rope,
      onScored: (points) => score += points,
    );

    expect(target.registerHit(), isTrue);
    expect(target.registerHit(), isFalse);
    expect(toy.registerHit(), isTrue);
    expect(toy.registerHit(), isFalse);
    expect(score, 325);
  });

  test('paw targets and water bowl invoke their gameplay callbacks once', () {
    var pawIndex = -1;
    var waterActivations = 0;
    final paw = PawMissionTarget(
      index: 2,
      position: Vector2.zero(),
      onHit: (index) => pawIndex = index,
    );
    final bowl = WaterBowl(
      position: Vector2.zero(),
      onActivated: () => waterActivations++,
    );

    expect(paw.registerHit(), isTrue);
    expect(paw.registerHit(), isFalse);
    expect(bowl.registerHit(), isTrue);
    expect(bowl.registerHit(), isFalse);
    expect(pawIndex, 2);
    expect(waterActivations, 1);
  });

  test('hydrant spinner awards its contact score once during cooldown', () {
    var score = 0;
    final hydrant = HydrantSpinner(
      position: Vector2.zero(),
      onScored: (points) => score += points,
    );

    expect(hydrant.registerHit(), isTrue);
    expect(hydrant.registerHit(), isFalse);
    expect(score, 150);
  });
}
