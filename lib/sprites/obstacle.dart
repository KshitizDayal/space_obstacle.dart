import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../constants/game_assets.dart';
import '../constants/game_constants.dart';
import '../game/main_game.dart';

class Obstacle extends Component with HasGameRef<MainGame> {
  final _random = Random();

  Obstacle();

  @override
  FutureOr<void> onLoad() {
    final heightMinusGround = gameRef.size.y -
        GameConstants.topHeight; // Subtract 100 from the total height
    final spacing = (heightMinusGround -
            (GameConstants.stoneSize * GameConstants.totalStones)) /
        (GameConstants.totalStones + 1);

    final List<int> emptyPositions = [];
    while (emptyPositions.length < GameConstants.emptySpots) {
      int randomPosition = _random.nextInt(GameConstants.totalStones);
      if (!emptyPositions.contains(randomPosition)) {
        emptyPositions.add(randomPosition);
      }
    }

    for (int i = 0; i < GameConstants.totalStones; i++) {
      if (!emptyPositions.contains(i)) {
        // final double yPosition = (i + 1) * spacing + i * stoneSize;
        final double yPosition = GameConstants.topHeight +
            spacing +
            (i * (GameConstants.stoneSize + spacing));
        final ObstacleStone obstacleStone =
            ObstacleStone(y: yPosition, stoneSize: GameConstants.stoneSize);
        add(obstacleStone);
      }
    }

    return super.onLoad();
  }
}

class ObstacleStone extends SpriteComponent with HasGameRef<MainGame> {
  @override
  final double y;
  final double stoneSize;

  ObstacleStone({required this.y, required this.stoneSize})
      : super(size: Vector2.all(stoneSize));

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(GameAssets.rock);
    super.onLoad();

    position = Vector2(gameRef.size.x, y);
    add(CircleHitbox());
  }
}
