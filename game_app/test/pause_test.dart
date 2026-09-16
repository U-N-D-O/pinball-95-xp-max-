import 'package:flutter_test/flutter_test.dart';

import 'package:pinball_neo_95/game/pinball_game.dart';

void main() {
  test('game pause controls stop and resume the engine', () {
    final game = PinballGame();

    expect(game.paused, isFalse);
    game.pauseGame();
    expect(game.paused, isTrue);
    game.resumeGame();
    expect(game.paused, isFalse);

    game.togglePause();
    expect(game.paused, isTrue);
    game.togglePause();
    expect(game.paused, isFalse);
  });
}
