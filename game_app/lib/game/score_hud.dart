import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'pinball_world.dart';

class ScoreHud extends PositionComponent with TapCallbacks {
  static const double pixel = 0.2;
  static const Map<String, List<String>> _glyphs = {
    '0': ['111', '101', '101', '101', '111'],
    '1': ['010', '110', '010', '010', '111'],
    '2': ['110', '001', '010', '100', '111'],
    '3': ['110', '001', '010', '001', '110'],
    '4': ['101', '101', '111', '001', '001'],
    '5': ['111', '100', '110', '001', '110'],
    '6': ['011', '100', '111', '101', '111'],
    '7': ['111', '001', '010', '010', '010'],
    '8': ['111', '101', '111', '101', '111'],
    '9': ['111', '101', '111', '001', '110'],
    'A': ['010', '101', '111', '101', '101'],
    'B': ['110', '101', '110', '101', '110'],
    'C': ['111', '100', '100', '100', '111'],
    'E': ['111', '100', '110', '100', '111'],
    'G': ['111', '100', '101', '101', '111'],
    'H': ['101', '101', '111', '101', '101'],
    'I': ['111', '010', '010', '010', '111'],
    'K': ['101', '110', '100', '110', '101'],
    'L': ['100', '100', '100', '100', '111'],
    'M': ['101', '111', '111', '101', '101'],
    'N': ['101', '111', '111', '111', '101'],
    'O': ['111', '101', '101', '101', '111'],
    'P': ['110', '101', '110', '100', '100'],
    'R': ['110', '101', '110', '101', '101'],
    'S': ['111', '100', '111', '001', '111'],
    'T': ['111', '010', '010', '010', '010'],
    'U': ['101', '101', '101', '101', '111'],
    'V': ['101', '101', '101', '101', '010'],
    'W': ['101', '101', '101', '111', '101'],
  };

  final PinballWorld world;

  ScoreHud(this.world) : super(size: Vector2(36, 64), priority: 300);

  @override
  void render(Canvas canvas) {
    final scorePaint = Paint()
      ..color = const Color(0xFFFFC928)
      ..isAntiAlias = false;
    final dimPaint = Paint()
      ..color = const Color(0xFF4B4A31)
      ..isAntiAlias = false;
    final gameOverPaint = Paint()
      ..color = const Color(0xFFD4473F)
      ..isAntiAlias = false;
    final missionPaint = Paint()
      ..color = const Color(0xFF7BE2B2)
      ..isAntiAlias = false;
    final readyPaint = Paint()
      ..color = const Color(0xFFFFF07D)
      ..isAntiAlias = false;

    final labelPaint = Paint()
      ..color = const Color(0xFF7B93A1)
      ..isAntiAlias = false;
    final waterLabelPaint = Paint()
      ..color = world.waterBonusActive
          ? const Color(0xFF74F0FF)
          : const Color(0xFF7B93A1)
      ..isAntiAlias = false;

    _drawPixelText(canvas, 'BALLS', 4.4, 1.0, labelPaint);
    _drawPixelText(canvas, 'PAWS', 11.0, 1.0, labelPaint);
    _drawPixelText(canvas, 'SCORE', 22.0, 1.0, labelPaint);
    _drawPixelText(canvas, 'WATER', 11.0, 4.0, waterLabelPaint);

    final score = world.score.toString().padLeft(7, '0');
    for (var index = 0; index < score.length; index++) {
      _drawDigit(canvas, score[index], 22.0 + (index * 1.2), 2.7, scorePaint);
    }

    for (var index = 0; index < PinballWorld.startingBalls; index++) {
      canvas.drawRect(
        Rect.fromLTWH(4.4 + (index * 1.2), 3.2, 0.7, 0.7),
        index < world.ballsRemaining ? scorePaint : dimPaint,
      );
    }

    for (var index = 0; index < 3; index++) {
      final isComplete =
          world.doghouseReady || index < world.pawMissionProgress;
      canvas.drawRect(
        Rect.fromLTWH(11.0 + (index * 1.2), 3.2, 0.7, 0.7),
        isComplete
            ? (world.doghouseReady ? readyPaint : missionPaint)
            : dimPaint,
      );
    }

    if (world.waterBonusActive) {
      final bonusBar = Paint()
        ..color = const Color(0xFF74F0FF)
        ..isAntiAlias = false;
      canvas.drawRect(
        Rect.fromLTWH(
          11.0,
          4.6,
          7.0 * (world.waterBonusTime / 8).clamp(0.0, 1.0),
          0.35,
        ),
        bonusBar,
      );
    }

    if (world.achievementMessage case final message?) {
      final banner = Paint()
        ..color = const Color(0xEE0C1B29)
        ..isAntiAlias = false;
      final border = Paint()
        ..color = const Color(0xFFFFC928)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.18
        ..isAntiAlias = false;
      canvas.drawRect(const Rect.fromLTWH(8.0, 7.0, 20.0, 2.0), banner);
      canvas.drawRect(const Rect.fromLTWH(8.0, 7.0, 20.0, 2.0), border);
      _drawPixelText(canvas, message, 10.0, 7.5, readyPaint);
    }

    if (world.gameOver) {
      _drawPixelText(canvas, 'GAME OVER', 11.7, 29.2, gameOverPaint, 0.35);
      _drawPixelText(canvas, 'SCORE', 11.0, 40.0, labelPaint);
      _drawPixelText(
        canvas,
        world.score.toString().padLeft(7, '0'),
        15.0,
        41.5,
        scorePaint,
      );
      _drawPixelText(canvas, 'BEST', 13.0, 44.0, labelPaint);
      _drawPixelText(
        canvas,
        world.highScore.toString().padLeft(7, '0'),
        15.0,
        45.5,
        readyPaint,
      );
      if (world.newHighScore) {
        _drawPixelText(canvas, 'NEW RECORD', 11.3, 49.0, readyPaint, 0.2);
      }
      _drawPixelText(canvas, 'TAP TO RESTART', 8.6, 35.0, readyPaint, 0.2);
    }
  }

  void restartFromTouch() {
    if (world.gameOver) {
      world.restartGame();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    restartFromTouch();
    event.handled = true;
  }

  void _drawPixelText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Paint paint, [
    double block = pixel,
  ]) {
    var cursor = x;
    for (final character in text.split('')) {
      if (character == ' ') {
        cursor += block * 2;
        continue;
      }

      final glyph = _glyphs[character];
      if (glyph == null) {
        cursor += block * 4;
        continue;
      }

      for (var row = 0; row < glyph.length; row++) {
        for (var column = 0; column < glyph[row].length; column++) {
          if (glyph[row][column] == '1') {
            canvas.drawRect(
              Rect.fromLTWH(
                cursor + (column * block),
                y + (row * block),
                block,
                block,
              ),
              paint,
            );
          }
        }
      }
      cursor += block * 4;
    }
  }

  void _drawDigit(
    Canvas canvas,
    String digit,
    double x,
    double y,
    Paint paint,
  ) {
    final bitmap = _glyphs[digit]!;
    for (var row = 0; row < bitmap.length; row++) {
      for (var column = 0; column < bitmap[row].length; column++) {
        if (bitmap[row][column] == '1') {
          canvas.drawRect(
            Rect.fromLTWH(
              x + (column * pixel),
              y + (row * pixel),
              pixel,
              pixel,
            ),
            paint,
          );
        }
      }
    }
  }
}
