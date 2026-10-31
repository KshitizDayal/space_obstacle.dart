import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../constants/game_assets.dart';
import 'hazard.dart';

class ObstacleStone extends SpriteComponent with Hazard {
  // Positioned relative to its column, which handles the scrolling
  ObstacleStone({required double y, required double stoneSize})
      : super(position: Vector2(0, y), size: Vector2.all(stoneSize));

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(GameAssets.rock);
    add(CircleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }
}
