import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/textstyle_assets.dart';

import '../constants/screen_id.dart';
import '../game/main_game.dart';
import 'game_button.dart';

class GamePause extends StatelessWidget {
  final MainGame game;
  static const String id = ScreenId.gamePause;

  const GamePause({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Paused", style: TextstyleAsset.bold45),
            const SizedBox(height: 40),
            GameButton(label: "Resume", onPressed: game.resumeGame),
            const SizedBox(height: 16),
            GameButton(
              label: "Restart",
              onPressed: game.startGame,
              color: GameColor.tertiary,
            ),
            const SizedBox(height: 16),
            GameButton(
              label: "Settings",
              onPressed: game.openSettings,
              color: GameColor.primary,
            ),
            const SizedBox(height: 16),
            GameButton(
              label: "Main menu",
              onPressed: game.goToMenu,
              color: GameColor.white,
            ),
          ],
        ),
      ),
    );
  }
}
