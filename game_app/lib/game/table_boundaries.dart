import 'package:flame_forge2d/flame_forge2d.dart';

import 'pinball_game.dart';
import 'table_tuning.dart';

class TableBoundaries extends BodyComponent<PinballGame> {
  static const double left = 2.8;
  static const double right = 30.2;
  static const double top = 9.0;
  static const double bottom = 61.0;

  TableBoundaries() : super(renderBody: false);

  @override
  Body createBody() {
    final body = world.createBody(
      BodyDef(type: BodyType.static, position: Vector2.zero()),
    );

    _addEdge(body, Vector2(left, top), Vector2(right, top));
    _addEdge(body, Vector2(left, top), Vector2(left, 49.0));
    _addEdge(body, Vector2(left, 49.0), Vector2(7.2, bottom));
    _addEdge(body, Vector2(right, top), Vector2(right, 49.0));
    _addEdge(body, Vector2(right, 49.0), Vector2(25.0, bottom));
    _addEdge(body, Vector2(7.2, bottom), Vector2(13.0, bottom));
    _addEdge(body, Vector2(23.0, bottom), Vector2(25.0, bottom));

    // The launcher lane is separate from the main playfield for now. The
    // launcher moves the ball into the playfield when the player fires it.
    _addEdge(body, Vector2(31.4, 9.0), Vector2(31.4, bottom));
    _addEdge(body, Vector2(34.4, 9.0), Vector2(34.4, bottom));

    return body;
  }

  void _addEdge(Body body, Vector2 start, Vector2 end) {
    final shape = EdgeShape()..set(start, end);
    body.createFixture(
      FixtureDef(
        shape,
        friction: 0.12,
        restitution: TableTuning.railRestitution,
      ),
    );
  }
}
