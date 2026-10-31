import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/constants/power_up_type.dart';
import 'package:space_obstacle/constants/textstyle_assets.dart';

import '../game/main_game.dart';
import '../constants/screen_id.dart';
import 'game_button.dart';

class GameInfo extends StatelessWidget {
  final MainGame game;
  static const String id = ScreenId.gameInfo;

  const GameInfo({super.key, required this.game});

  static const Map<PowerUpType, String> _powerUpHelp = {
    PowerUpType.shield: "Absorbs one hit",
    PowerUpType.shrink: "Smaller UFO for a few seconds",
    PowerUpType.slowMo: "Slows everything down",
    PowerUpType.magnet: "Pulls nearby coins to you",
    PowerUpType.blaster:
        "${GameConstants.blasterAmmo} shots: tap FIRE or press Space",
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("How to play", style: TextstyleAsset.bold45),
                  ),
                  const SizedBox(height: 16),
                  _line(
                    "Drag (or use the arrow keys) to dodge the rocks. "
                    "Every column you pass is a point.",
                  ),
                  _line(
                    "You have ${GameConstants.startLives} lives. "
                    "Your fuel drains constantly, so grab fuel cells (F) "
                    "or you'll run dry.",
                  ),
                  _line(
                    "Coins are worth +${GameConstants.coinScore} points. "
                    "The game speeds up as your score climbs.",
                  ),
                  _line(
                    "Every ${GameConstants.eventEveryScore} points an event "
                    "hits: a meteor shower, homing asteroids or a black hole. "
                    "Survive it for +${GameConstants.eventSurviveBonus}.",
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Power-ups",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: GameColor.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final entry in _powerUpHelp.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: entry.key.color,
                            child: Text(
                              entry.key.symbol,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: GameColor.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${entry.key.label}: ${entry.value}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: GameColor.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: GameButton(
                      label: "Back",
                      onPressed: () => game.overlays.remove(ScreenId.gameInfo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _line(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: GameColor.white),
      ),
    );
  }
}
