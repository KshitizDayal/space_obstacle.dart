import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_obstacle/game/main_game.dart';

import '../constants/game_constants.dart';
import 'obstacle.dart';

class Obstacles extends PositionComponent
    with HasGameRef<MainGame>, CollisionCallbacks {
  Obstacles();

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    addAll([
      Obstacle(),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= GameConstants.gameSpeed * dt;

    // if (gameRef.isHit == true) {
    //   removeFromParent();
    //   gameRef.isHit = false;
    // }

    if (position.x < -gameRef.size.x - GameConstants.obstacleSize) {
      removeFromParent();
    }

    // if (gameRef.resetObstacles) {
    //   removeFromParent();
    //   gameRef.resetObstacles = false;
    // }
  }

  // void updateScore() {
  //   gameRef.isHit = true;
  //   gameRef.player.score += 1;

  //   // FlameAudio.play(Assets.pointAudio);
  // }
}
