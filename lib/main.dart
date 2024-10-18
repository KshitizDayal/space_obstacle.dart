import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/game/main_game.dart';
import 'package:space_obstacle/screens/game_info.dart';
import 'package:space_obstacle/screens/game_level.dart';
import 'package:space_obstacle/screens/game_pause.dart';
import 'package:space_obstacle/screens/game_start.dart';

import 'constants/screen_id.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = MainGame();
  // await SecureStorage.instance.checkUserHighScore();

  runApp(
    GameWidget(
      game: game,
      initialActiveOverlays: const [ScreenId.gameStart],
      overlayBuilderMap: {
        ScreenId.gameStart: (context, _) => GameStart(game: game),
        ScreenId.gamePause: (context, _) => GamePause(game: game),
        ScreenId.gameInfo: (context, _) => GameInfo(game: game),
        ScreenId.gameLevel: (context, _) => GameLevel(game: game),
      },
    ),
  );
}
