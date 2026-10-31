import 'package:flutter/material.dart';
import 'package:space_obstacle/constants/game_audio.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/textstyle_assets.dart';

import '../constants/screen_id.dart';
import '../game/main_game.dart';
import 'game_button.dart';

class GameSettings extends StatefulWidget {
  final MainGame game;
  static const String id = ScreenId.gameSettings;

  const GameSettings({super.key, required this.game});

  @override
  State<GameSettings> createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings> {
  MainGame get game => widget.game;

  @override
  Widget build(BuildContext context) {
    final save = game.save;

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Settings", style: TextstyleAsset.bold45),
                  const SizedBox(height: 24),
                  _switch("Mute all sound", save.muted, (value) {
                    save.muted = value;
                    game.feedback.applySettings();
                  }),
                  _slider("Music volume", save.musicVolume, (value) {
                    save.musicVolume = value;
                    game.feedback.applySettings();
                  }),
                  _slider(
                    "Sound effects volume",
                    save.sfxVolume,
                    (value) => save.sfxVolume = value,
                    // Play a sample once the slider is let go so the level can be judged
                    onChangeEnd: (_) => game.feedback.play(GameAudio.coin),
                  ),
                  _switch("Vibration", save.haptics, (value) {
                    save.haptics = value;
                    if (value) game.feedback.lightHaptic();
                  }),
                  const SizedBox(height: 32),
                  GameButton(label: "Back", onPressed: game.closeSettings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: _labelStyle),
      value: value,
      activeTrackColor: GameColor.secondary,
      onChanged: (value) => setState(() => onChanged(value)),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged,
      {ValueChanged<double>? onChangeEnd}) {
    final muted = game.save.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ${(value * 100).round()}%",
            style: _labelStyle.copyWith(
              color: muted ? Colors.white38 : GameColor.white,
            ),
          ),
          Slider(
            value: value,
            activeColor: GameColor.secondary,
            onChanged:
                muted ? null : (value) => setState(() => onChanged(value)),
            onChangeEnd: muted ? null : onChangeEnd,
          ),
        ],
      ),
    );
  }

  static const _labelStyle = TextStyle(fontSize: 18, color: GameColor.white);
}
