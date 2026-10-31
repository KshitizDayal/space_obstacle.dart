import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_obstacle/constants/game_assets.dart';
import 'package:space_obstacle/game/main_game.dart';

import 'hazard.dart';

/// Small fast rock that streaks in diagonally from the top during a meteor shower.
class Meteor extends SpriteComponent with HasGameReference<MainGame>, Hazard {
  final _random = Random();
  late Vector2 _velocity;
  late double _spin;

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(GameAssets.rock);
    size = Vector2.all(game.stoneSize * 0.5);
    anchor = Anchor.center;
    position = Vector2(
      game.size.x * (0.45 + _random.nextDouble() * 0.65),
      game.playTop - size.y,
    );
    _velocity = Vector2(
      -(220 + _random.nextDouble() * 120),
      200 + _random.nextDouble() * 120,
    );
    _spin = (_random.nextDouble() - 0.5) * 8;
    add(CircleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
    angle += _spin * dt;
    if (position.x < -size.x || position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}
