import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/textstyle_assets.dart';

import '../constants/screen_id.dart';
import '../game/main_game.dart';
import 'game_button.dart';

class GameOver extends StatelessWidget {
  final MainGame game;
  static const String id = ScreenId.gameOver;

  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final isNewBest = game.isNewBest;

    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Game Over", style: TextstyleAsset.bold45),
            const SizedBox(height: 8),
            Text(
              game.gameOverReason,
              style: const TextStyle(fontSize: 18, color: GameColor.white),
            ),
            const SizedBox(height: 32),
            Text(
              "Score: ${game.score}",
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: GameColor.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isNewBest ? "New best!" : "Best: ${game.bestScore}",
              style: const TextStyle(fontSize: 20, color: GameColor.secondary),
            ),
            const SizedBox(height: 4),
            Text(
              "Coins collected: ${game.coins}",
              style: const TextStyle(fontSize: 18, color: GameColor.coin),
            ),
            const SizedBox(height: 40),
            GameButton(label: "Play again", onPressed: game.startGame),
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
