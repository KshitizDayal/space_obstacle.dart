import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:space_obstacle/constants/game_assets.dart';
import 'package:space_obstacle/game/main_game.dart';

class Pause extends SpriteComponent
    with HasGameReference<MainGame>, TapCallbacks {
  Pause() : super(priority: 10);

  @override
  FutureOr<void> onLoad() async {
    final background = await Flame.images.load(GameAssets.pause);
    size = Vector2(30, 30);
    sprite = Sprite(background);
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Top-right, on the HUD's first row
    final row1 = game.playTop * 0.35;
    position = Vector2(size.x - 46, row1 - 15);
  }

  @override
  void render(Canvas canvas) {
    if (game.state == GameState.playing) super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.pauseGame();
  }
}
