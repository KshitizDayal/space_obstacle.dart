import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:space_obstacle/sprites/background.dart';

import '../constants/game_constants.dart';
import '../sprites/obstacles.dart';
import '../sprites/pause.dart';
import '../sprites/player.dart';

class MainGame extends FlameGame
    with VerticalDragDetector, KeyboardEvents, HasCollisionDetection {
  late Player player;
  late Obstacles obstacles;
  Timer interval = Timer(GameConstants.columnInterval, repeat: true);
  late TextComponent score;
  bool isHit = false;
  bool resetObstacles = false;
  late Pause pause;
  @override
  FutureOr<void> onLoad() {
    addAll([
      Background(),
      player = Player(),
      obstacles = Obstacles(),
      // score = builScore(),
      pause = Pause(),
      FpsTextComponent(
        position: Vector2(size.x / 2 * 0.2, size.y / 2 * 0.17),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            fontFamily: "Game",
            color: Color(0xFFE7CCCC),
          ),
        ),
      ),
    ]);
    interval.onTick = () => add(Obstacles());
    return super.onLoad();
  }

  // TextComponent builScore() {
  //   return TextComponent(
  //     text: "Score: 0",
  //     position: Vector2(size.x / 2, size.y / 2 * 0.2),
  //     anchor: Anchor.center,
  //     textRenderer: TextPaint(
  //       style: const TextStyle(
  //         fontSize: 40,
  //         fontWeight: FontWeight.bold,
  //         fontFamily: "Game",
  //       ),
  //     ),
  //   );
  // }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
    // debugMode = true;

    // score.text = "Score: ${player.score}";
  }

  @override
  void onVerticalDragUpdate(DragUpdateInfo info) {
    player.move(info.delta.global.y);
    super.onVerticalDragUpdate(info);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    const double movespeed = 55.0;

    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        player.move(-movespeed);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        player.move(movespeed);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
