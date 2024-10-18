import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:space_obstacle/sprites/background.dart';

class MainGame extends FlameGame
    with VerticalDragDetector, KeyboardEvents, HasCollisionDetection {
  @override
  FutureOr<void> onLoad() {
    addAll([
      Background(),
    ]);
    return super.onLoad();
  }
}
