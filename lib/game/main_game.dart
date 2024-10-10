import 'package:flame/game.dart';
import 'package:flame/input.dart';

class MainGame extends FlameGame
    with VerticalDragDetector, KeyboardEvents, HasCollisionDetection {}
