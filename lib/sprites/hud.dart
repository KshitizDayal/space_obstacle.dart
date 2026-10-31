import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/constants/power_up_type.dart';
import 'package:space_obstacle/game/main_game.dart';

import 'collectible.dart';

/// Lives, fuel, score, coins and active power-ups, drawn in the band above the play area.
class Hud extends Component with HasGameReference<MainGame> {
  Hud() : super(priority: 10);

  static const double _margin = 16;
  static const double _fuelBarWidth = 90;
  static const double _badgeRadius = 14;

  final _scorePaint = TextPaint(
    style: const TextStyle(
      fontSize: 24,
      fontFamily: "Game",
      color: GameColor.white,
    ),
  );
  final _smallPaint = TextPaint(
    style: const TextStyle(
      fontSize: 16,
      fontFamily: "Game",
      color: GameColor.white,
    ),
  );
  final _heartFull = Paint()..color = GameColor.danger;
  final _heartEmpty = Paint()
    ..color = GameColor.danger
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final _fuelBack = Paint()..color = const Color(0x55FFFFFF);
  final _fuelFill = Paint();

  @override
  void render(Canvas canvas) {
    if (game.state == GameState.menu) return;

    final row1 = game.playTop * 0.35;
    final row2 = game.playTop * 0.7;
    final centerX = game.size.x / 2;

    for (var i = 0; i < GameConstants.startLives; i++) {
      _drawHeart(
        canvas,
        Offset(_margin + 10 + i * 26, row1),
        10,
        i < game.lives ? _heartFull : _heartEmpty,
      );
    }

    final fuelRatio = game.fuel / GameConstants.maxFuel;
    _fuelFill.color = fuelRatio > 0.5
        ? GameColor.fuel
        : fuelRatio > 0.25
            ? GameColor.primary
            : GameColor.danger;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_margin, row2 - 5, _fuelBarWidth, 10),
        const Radius.circular(5),
      ),
      _fuelBack,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_margin, row2 - 5, _fuelBarWidth * fuelRatio, 10),
        const Radius.circular(5),
      ),
      _fuelFill,
    );

    _scorePaint.render(canvas, "Score: ${game.score}", Vector2(centerX, row1),
        anchor: Anchor.center);
    _smallPaint.render(canvas, "Coins: ${game.coins}", Vector2(centerX, row2),
        anchor: Anchor.center);

    // Active power-ups, right-aligned under the pause button
    var x = game.size.x - _margin - _badgeRadius;
    void badge(PowerUpType type, double progress) {
      drawPowerUpBadge(canvas, Offset(x, row2), _badgeRadius, type,
          progress: progress);
      x -= _badgeRadius * 2 + 6;
    }

    if (game.hasShield) badge(PowerUpType.shield, 1);
    for (final type in [
      PowerUpType.shrink,
      PowerUpType.slowMo,
      PowerUpType.magnet,
    ]) {
      if (game.isActive(type)) {
        badge(type, game.powerUpTimers[type]! / type.duration);
      }
    }
    if (game.blasterAmmo > 0) {
      badge(
        PowerUpType.blaster,
        (game.blasterAmmo / GameConstants.blasterAmmo).clamp(0.0, 1.0),
      );
    }
  }

  void _drawHeart(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(c.dx - r * 2, c.dy - r * 0.2, c.dx - r * 0.8, c.dy - r * 1.6,
          c.dx, c.dy - r * 0.5)
      ..cubicTo(c.dx + r * 0.8, c.dy - r * 1.6, c.dx + r * 2, c.dy - r * 0.2,
          c.dx, c.dy + r)
      ..close();
    canvas.drawPath(path, paint);
  }
}
