import 'dart:ui';

import 'package:flame/components.dart';

class TableDecorations extends PositionComponent {
  TableDecorations()
    : super(position: Vector2.zero(), size: Vector2(36, 64), priority: 5);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final cluster = await Sprite.load('sprites/grass_flower_cluster.png');
    for (final point in [
      Vector2(5.2, 29.0),
      Vector2(28.0, 26.0),
      Vector2(7.0, 48.0),
      Vector2(28.5, 51.0),
    ]) {
      add(
        SpriteComponent(
          sprite: cluster,
          position: point,
          size: Vector2.all(1.8),
          anchor: Anchor.center,
          paint: Paint()..filterQuality = FilterQuality.none,
        ),
      );
    }

    final rock = await Sprite.load('sprites/rock_decoration.png');
    for (final point in [
      Vector2(5.5, 13.25),
      Vector2(28.5, 14.25),
      Vector2(8.5, 55.25),
      Vector2(27.5, 57.25),
    ]) {
      add(
        SpriteComponent(
          sprite: rock,
          position: point,
          size: Vector2.all(1.6),
          anchor: Anchor.center,
          paint: Paint()..filterQuality = FilterQuality.none,
        ),
      );
    }

    final paw = await Sprite.load('sprites/paw_decoration.png');
    for (final point in [
      Vector2(13.45, 40.6),
      Vector2(19.45, 47.6),
      Vector2(11.45, 29.1),
    ]) {
      add(
        SpriteComponent(
          sprite: paw,
          position: point,
          size: Vector2.all(1.9),
          anchor: Anchor.center,
          paint: Paint()..filterQuality = FilterQuality.none,
        ),
      );
    }
  }
}
