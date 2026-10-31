import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_audio.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/constants/power_up_type.dart';
import 'package:space_obstacle/game/main_game.dart';

/// Something the player picks up by flying into it. Rides along inside an obstacle column's gap.
abstract class Collectible extends PositionComponent
    with HasGameReference<MainGame> {
  Collectible({required super.position}) : super(anchor: Anchor.center);

  double _time = 0;

  /// Picks what (if anything) goes in a column's gap. Fuel shows up more often when the tank is low.
  static Collectible? random(Random random,
      {required bool fuelLow, required Vector2 position}) {
    final fuelChance = fuelLow ? 0.35 : 0.15;
    final roll = random.nextDouble();
    if (roll < fuelChance) return FuelCell(position: position);
    if (roll < fuelChance + 0.12) {
      final type =
          PowerUpType.values[random.nextInt(PowerUpType.values.length)];
      return PowerUpPickup(type: type, position: position);
    }
    if (roll < fuelChance + 0.12 + 0.45) return Coin(position: position);
    return null;
  }

  @override
  FutureOr<void> onLoad() {
    size = Vector2.all(game.stoneSize * 0.36);
    add(CircleHitbox(collisionType: CollisionType.passive));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // Gentle pulse so pickups stand out from the rocks
    scale = Vector2.all(1 + sin(_time * 6) * 0.08);
  }

  void collect() {
    if (isRemoving) return;
    onCollect();
    removeFromParent();
  }

  void onCollect();
}

class Coin extends Collectible {
  Coin({required super.position});

  final _fill = Paint()..color = GameColor.coin;
  final _rim = Paint()
    ..color = const Color(0xFFB8860B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isActive(PowerUpType.magnet)) return;

    final toPlayer = game.player.absolutePosition - absolutePosition;
    if (toPlayer.length < GameConstants.magnetRadius) {
      position += toPlayer.normalized() * GameConstants.magnetPull * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();
    canvas.drawCircle(center, size.x / 2, _fill);
    canvas.drawCircle(center, size.x / 2 - 4, _rim);
  }

  @override
  void onCollect() {
    game.coins++;
    game.addScore(GameConstants.coinScore);
    game.feedback.play(GameAudio.coin);
    game.showText("+${GameConstants.coinScore}", absolutePosition,
        color: GameColor.coin);
  }
}

class FuelCell extends Collectible {
  FuelCell({required super.position});

  final _fill = Paint()..color = GameColor.fuel;
  final _label = TextPaint(
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: GameColor.white,
    ),
  );

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      _fill,
    );
    _label.render(canvas, "F", size / 2, anchor: Anchor.center);
  }

  @override
  void onCollect() {
    game.fuel =
        min(GameConstants.maxFuel, game.fuel + GameConstants.fuelCellAmount);
    game.feedback.play(GameAudio.powerUp);
    game.showText(
        "FUEL +${GameConstants.fuelCellAmount.toInt()}", absolutePosition,
        color: GameColor.fuel);
  }
}

class PowerUpPickup extends Collectible {
  final PowerUpType type;

  PowerUpPickup({required this.type, required super.position});

  @override
  void render(Canvas canvas) {
    drawPowerUpBadge(canvas, (size / 2).toOffset(), size.x / 2, type);
  }

  @override
  void onCollect() {
    game.activatePowerUp(type);
    game.showText(type.label, absolutePosition, color: type.color);
  }
}

/// Round badge with the power-up's symbol. [progress] draws the remaining time as an arc.
void drawPowerUpBadge(
    Canvas canvas, Offset center, double radius, PowerUpType type,
    {double progress = 1}) {
  canvas.drawCircle(center, radius, Paint()..color = const Color(0xCC1A1033));
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius - 2),
    -pi / 2,
    pi * 2 * progress,
    false,
    Paint()
      ..color = type.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  TextPaint(
    style: TextStyle(
      fontSize: radius,
      fontWeight: FontWeight.bold,
      color: type.color,
    ),
  ).render(canvas, type.symbol, Vector2(center.dx, center.dy),
      anchor: Anchor.center);
}
