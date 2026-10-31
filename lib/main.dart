import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_obstacle/game/game_feedback.dart';
import 'package:space_obstacle/game/main_game.dart';
import 'package:space_obstacle/game/save_game.dart';
import 'package:space_obstacle/screens/game_info.dart';
import 'package:space_obstacle/screens/game_level.dart';
import 'package:space_obstacle/screens/game_over.dart';
import 'package:space_obstacle/screens/game_pause.dart';
import 'package:space_obstacle/screens/game_settings.dart';
import 'package:space_obstacle/screens/game_start.dart';

import 'constants/screen_id.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final save = await SaveGame.load();
  final game = MainGame(save: save, feedback: GameFeedback(save));

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(
        game: game,
        initialActiveOverlays: const [ScreenId.gameStart],
        overlayBuilderMap: {
          ScreenId.gameStart: (context, _) => GameStart(game: game),
          ScreenId.gamePause: (context, _) => GamePause(game: game),
          ScreenId.gameInfo: (context, _) => GameInfo(game: game),
          ScreenId.gameLevel: (context, _) => GameLevel(game: game),
          ScreenId.gameOver: (context, _) => GameOver(game: game),
          ScreenId.gameSettings: (context, _) => GameSettings(game: game),
        },
      ),
    ),
  );
}
