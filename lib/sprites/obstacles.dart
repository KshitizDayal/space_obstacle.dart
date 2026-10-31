import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:space_obstacle/game/main_game.dart';

import '../constants/game_constants.dart';
import 'collectible.dart';
import 'obstacle.dart';

/// One column of stones scrolling towards the player, with a pickup in one of its gaps.
class Obstacles extends PositionComponent with HasGameReference<MainGame> {
  final int emptySpots;

  /// Moving columns bob up and down, so the gaps shift while you line up.
  final bool moving;

  final _random = Random();
  late double _stoneSize;
  double _wavePhase = 0;
  bool _passed = false;

  Obstacles({required this.emptySpots, this.moving = false});

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x, 0);
    _stoneSize = game.stoneSize;
    _wavePhase = _random.nextDouble() * pi * 2;

    final top = game.playTop;
    final spacing =
        (game.size.y - top - _stoneSize * GameConstants.totalStones) /
            (GameConstants.totalStones + 1);

    final List<int> emptyPositions = [];
    while (emptyPositions.length < emptySpots) {
      int randomPosition = _random.nextInt(GameConstants.totalStones);
      if (!emptyPositions.contains(randomPosition)) {
        emptyPositions.add(randomPosition);
      }
    }
    final pickupSlot = emptyPositions.firstOrNull;

    for (int i = 0; i < GameConstants.totalStones; i++) {
      final double yPosition = top + spacing + (i * (_stoneSize + spacing));
      if (!emptyPositions.contains(i)) {
        add(ObstacleStone(y: yPosition, stoneSize: _stoneSize));
      } else if (i == pickupSlot) {
        final pickup = Collectible.random(
          _random,
          fuelLow: game.fuel < GameConstants.lowFuel,
          position: Vector2(_stoneSize / 2, yPosition + _stoneSize / 2),
        );
        if (pickup != null) add(pickup);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isRemoving) return;

    position.x -= game.spawner.scrollSpeed * dt;

    if (moving) {
      _wavePhase += GameConstants.columnWaveSpeed * dt;
      position.y = sin(_wavePhase) * GameConstants.columnWaveAmplitude;
    }

    final player = game.player;
    if (!_passed && position.x + _stoneSize < player.x - player.width / 2) {
      _passed = true;
      game.addScore(1);
    }

    if (position.x < -_stoneSize) {
      removeFromParent();
    }
  }
}
