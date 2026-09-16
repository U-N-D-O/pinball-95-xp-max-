import 'dart:ui';

import 'package:flame/components.dart';

import 'pinball_game.dart';

class PlayfieldComponent extends PositionComponent {
  PlayfieldComponent()
    : super(
        position: Vector2.zero(),
        size: Vector2(PinballGame.gameWidth, PinballGame.gameHeight),
        scale: Vector2.all(1 / PinballGame.physicsPixelsPerUnit),
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final board = Rect.fromLTWH(0, 0, size.x, size.y);
    final innerBoard = Rect.fromLTWH(12, 12, size.x - 24, size.y - 24);
    final playArea = Rect.fromLTWH(22, 72, 286, 544);

    canvas.drawRect(board, _paint(const Color(0xFF111B2B)));
    canvas.drawRect(innerBoard, _paint(const Color(0xFF26374A)));
    canvas.drawRect(playArea, _paint(const Color(0xFF18533F)));

    _drawPixelBorder(canvas, innerBoard, const Color(0xFF6A8CA1), 4);
    _drawPixelBorder(canvas, playArea, const Color(0xFF0A2E2C), 5);
    _drawTopDisplay(canvas);
    _drawLauncherLane(canvas);
    _drawRails(canvas);
    _drawBumpers(canvas);
    _drawTargets(canvas);
    _drawFlipperPlaceholders(canvas);
  }

  void _drawTopDisplay(Canvas canvas) {
    final display = Rect.fromLTWH(30, 22, 278, 35);
    canvas.drawRect(display, _paint(const Color(0xFF091522)));
    _drawPixelBorder(canvas, display, const Color(0xFF46677D), 3);

    for (var index = 0; index < 3; index++) {
      canvas.drawRect(
        Rect.fromLTWH(44 + (index * 12).toDouble(), 34, 7, 7),
        _paint(const Color(0xFFFFC928)),
      );
    }

    final scoreLine = Paint()
      ..color = const Color(0xFF7BE2B2)
      ..strokeWidth = 3
      ..isAntiAlias = false;
    canvas.drawLine(const Offset(224, 34), const Offset(287, 34), scoreLine);
  }

  void _drawLauncherLane(Canvas canvas) {
    final lane = Rect.fromLTWH(314, 72, 30, 544);
    canvas.drawRect(lane, _paint(const Color(0xFF0C1B29)));
    _drawPixelBorder(canvas, lane, const Color(0xFF6A8CA1), 3);

    final plunger = Rect.fromLTWH(320, 566, 18, 42);
    canvas.drawRect(plunger, _paint(const Color(0xFFB83A32)));
    canvas.drawRect(
      const Rect.fromLTWH(324, 572, 10, 24),
      _paint(const Color(0xFFE88943)),
    );
  }

  void _drawRails(Canvas canvas) {
    final railPaint = Paint()
      ..color = const Color(0xFFB8D0D2)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = false;

    canvas.drawLine(const Offset(28, 90), const Offset(28, 505), railPaint);
    canvas.drawLine(const Offset(302, 90), const Offset(302, 505), railPaint);
    canvas.drawLine(const Offset(28, 505), const Offset(72, 606), railPaint);
    canvas.drawLine(const Offset(302, 505), const Offset(258, 606), railPaint);
  }

  void _drawBumpers(Canvas canvas) {
    _drawBumper(canvas, const Offset(105, 175), const Color(0xFFD4473F));
    _drawBumper(canvas, const Offset(215, 175), const Color(0xFFD4473F));
    _drawBumper(canvas, const Offset(160, 255), const Color(0xFF317BD0));
  }

  void _drawBumper(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(center, 26, _paint(const Color(0xFF0C1B29)));
    canvas.drawCircle(center, 22, _paint(color));
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 14, height: 5),
      _paint(const Color(0xFFFFE8A4)),
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 7),
        width: 5,
        height: 5,
      ),
      _paint(const Color(0xFFFFE8A4)),
    );
  }

  void _drawTargets(Canvas canvas) {
    for (var index = 0; index < 3; index++) {
      final x = 88 + (index * 72);
      final target = Rect.fromLTWH(x.toDouble(), 330, 42, 18);
      canvas.drawRect(target, _paint(const Color(0xFF0C1B29)));
      canvas.drawRect(
        Rect.fromLTWH(x + 4.0, 334, 34, 10),
        _paint(const Color(0xFFFFC928)),
      );
    }
  }

  void _drawFlipperPlaceholders(Canvas canvas) {
    final left = Path()
      ..moveTo(62, 565)
      ..lineTo(142, 590)
      ..lineTo(138, 608)
      ..lineTo(57, 582)
      ..close();
    final right = Path()
      ..moveTo(218, 590)
      ..lineTo(298, 565)
      ..lineTo(303, 582)
      ..lineTo(222, 608)
      ..close();

    canvas.drawPath(left, _paint(const Color(0xFFE6E2D0)));
    canvas.drawPath(right, _paint(const Color(0xFFE6E2D0)));
    _drawPixelBorder(
      canvas,
      const Rect.fromLTWH(72, 544, 215, 72),
      const Color(0xFF0C1B29),
      2,
    );

    canvas.drawCircle(
      const Offset(160, 595),
      15,
      _paint(const Color(0xFFFFC928)),
    );
    canvas.drawCircle(
      const Offset(160, 595),
      8,
      _paint(const Color(0xFF7A4B20)),
    );
  }

  void _drawPixelBorder(Canvas canvas, Rect rect, Color color, double width) {
    final border = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..isAntiAlias = false;
    canvas.drawRect(rect, border);
  }

  Paint _paint(Color color) {
    return Paint()
      ..color = color
      ..isAntiAlias = false;
  }
}
