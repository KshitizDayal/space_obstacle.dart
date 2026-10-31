import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/game/main_game.dart';

/// Sits near the right edge and drags the player towards its height while columns keep coming.
class BlackHole extends PositionComponent with HasGameReference<MainGame> {
  double _growth = 0;
  bool _collapsing = false;

  final _ring = Paint()
    ..color = const Color(0xFFB388FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  FutureOr<void> onLoad() {
    size = Vector2.all(game.stoneSize * 1.3);
    anchor = Anchor.center;
    final playTop = game.playTop;
    final band = game.size.y - playTop;
    position = Vector2(
      game.size.x - size.x * 0.6,
      playTop + band * (0.2 + Random().nextDouble() * 0.6),
    );
    return super.onLoad();
  }

  void collapse() => _collapsing = true;

  @override
  void update(double dt) {
    super.update(dt);
    angle += 2 * dt;

    _growth = (_growth + (_collapsing ? -dt : dt)).clamp(0.0, 1.0);
    scale = Vector2.all(_growth);
    if (_collapsing && _growth == 0) {
      removeFromParent();
      return;
    }

    final player = game.player;
    final dy = position.y - player.y;
    player.move(
        dy.sign * min(dy.abs(), GameConstants.blackHolePull * _growth * dt));
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.black, Color(0xFF2A0E4F), Colors.transparent],
          stops: [0.35, 0.75, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * (0.5 + i * 0.15)),
        i * 2.1,
        pi * 0.8,
        false,
        _ring,
      );
    }
  }
}
