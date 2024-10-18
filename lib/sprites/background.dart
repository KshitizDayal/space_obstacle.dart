import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:space_obstacle/game/main_game.dart';

import '../constants/game_assets.dart';

class Background extends SpriteComponent with HasGameRef<MainGame> {
  Background();

  @override
  FutureOr<void> onLoad() async {
    final background = await Flame.images.load(GameAssets.background);
    size = gameRef.size;
    sprite = Sprite(background);
    return super.onLoad();
  }
}
