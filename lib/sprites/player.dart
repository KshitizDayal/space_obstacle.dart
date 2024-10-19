import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:space_obstacle/constants/game_assets.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/game/main_game.dart';

class Player extends SpriteComponent
    with HasGameRef<MainGame>, CollisionCallbacks {
  // int score = 0;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load(GameAssets.ufo);
    size = Vector2.all(GameConstants.playerheight);
    position = Vector2(75, gameRef.size.y / 2 - size.y / 2);
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  void move(double delatY) {
    double newY = position.y + delatY;

    double minY = -(gameRef.size.y) + size.y / 2;
    double maxY = (gameRef.size.y) - size.y / 2;
    newY = newY.clamp(minY, maxY);

    position.y = newY;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    gameOver();
    // gameRef.obstacleColumn.updateScore();
    // FlameAudio.play(Assets.collisionAudio);
  }

  void gameOver() {
    gameRef.pauseEngine();
    game.isHit = true;
    // FlameAudio.play(Assets.collisionAudio);
    // gameRef.overlays.add('gamePause');
  }

  void resetPosition() {
    position = Vector2(75, gameRef.size.y / 2 - size.y / 2);
    // score = 0;
    // gameRef.resetObstacles = true;
  }
}
