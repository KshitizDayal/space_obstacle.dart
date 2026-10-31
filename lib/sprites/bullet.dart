import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/game/main_game.dart';

import 'hazard.dart';

/// Blaster shot: destroys the first hazard it touches.
class Bullet extends RectangleComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  Bullet({required super.position})
      : super(
          size: Vector2(18, 5),
          anchor: Anchor.center,
          paint: Paint()..color = GameColor.secondary,
        );

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += GameConstants.bulletSpeed * dt;
    if (position.x > game.size.x + size.x) removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Hazard && !isRemoving) {
      other.removeFromParent();
      removeFromParent();
    }
  }
}
