import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_assets.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/game/main_game.dart';

import 'hazard.dart';

/// Big asteroid that steers towards the player's height until it gets close, then commits.
class Chaser extends SpriteComponent with HasGameReference<MainGame>, Hazard {
  static const double _maxTurnSpeed = 110;

  final _glow = Paint()
    ..color = GameColor.danger.withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(GameAssets.rock);
    size = Vector2.all(game.stoneSize * 0.9);
    anchor = Anchor.center;
    final playTop = game.playTop;
    position = Vector2(
      game.size.x + size.x,
      playTop + Random().nextDouble() * (game.size.y - playTop),
    );
    add(CircleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final player = game.player;
    position.x -= game.spawner.scrollSpeed * 1.2 * dt;
    angle -= 1.5 * dt;

    if (position.x > player.x + 150) {
      final dy = player.y - position.y;
      position.y += dy.sign * min(dy.abs(), _maxTurnSpeed * dt);
    }

    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle((size / 2).toOffset(), size.x * 0.6, _glow);
    super.render(canvas);
  }
}
