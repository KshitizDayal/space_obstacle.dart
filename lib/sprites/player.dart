import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:space_obstacle/constants/game_assets.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/constants/power_up_type.dart';
import 'package:space_obstacle/game/main_game.dart';

import 'collectible.dart';
import 'hazard.dart';

class Player extends SpriteComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  final _shieldPaint = Paint()
    ..color = PowerUpType.shield.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load(GameAssets.ufo);
    size = Vector2.all(game.playerSize);
    anchor = Anchor.center;
    resetPosition();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Ease in and out of the shrink power-up; the hitbox scales with it
    final targetScale =
        game.isActive(PowerUpType.shrink) ? GameConstants.shrinkScale : 1.0;
    final newScale =
        scale.x + (targetScale - scale.x) * (dt * 10).clamp(0.0, 1.0);
    scale = Vector2.all(newScale);

    // Blink while invincible after a hit
    final blinkOff =
        game.isInvincible && (game.invincibleTimer * 10).floor().isEven;
    setOpacity(blinkOff ? 0.3 : 1);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (game.hasShield) {
      canvas.drawCircle((size / 2).toOffset(), size.x * 0.75, _shieldPaint);
    }
  }

  void move(double delatY) {
    final halfHeight = size.y * scale.y / 2;
    double minY = game.playTop + halfHeight;
    double maxY = game.size.y - halfHeight;
    position.y = (position.y + delatY).clamp(minY, maxY);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Hazard) {
      game.onPlayerHit(other);
    } else if (other is Collectible) {
      other.collect();
    }
  }

  void resetPosition() {
    final playTop = game.playTop;
    position = Vector2(
      GameConstants.playerX,
      playTop + (game.size.y - playTop) / 2,
    );
    scale = Vector2.all(1);
    setOpacity(1);
  }
}
