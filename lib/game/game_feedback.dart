import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:space_obstacle/constants/game_audio.dart';
import 'package:space_obstacle/game/save_game.dart';

/// Music, sound effects and haptics, all following the player's settings.
class GameFeedback {
  final SaveGame save;

  /// Silent feedback never touches the audio or haptics plugins (used in tests).
  final bool _silent;

  GameFeedback(this.save) : _silent = false;
  GameFeedback.silent(this.save) : _silent = true;

  double get _musicVolume => save.muted ? 0 : save.musicVolume;
  double get _sfxVolume => save.muted ? 0 : save.sfxVolume;

  Future<void> load() async {
    if (_silent) return;
    try {
      // Also pauses the music while the app is in the background
      await FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll(GameAudio.effects);
    } catch (error) {
      // A missing audio backend shouldn't stop the game from starting
      debugPrint("Audio failed to load: $error");
    }
  }

  void startMusic() {
    if (_silent) return;
    FlameAudio.bgm.play(GameAudio.backgroundMusic, volume: _musicVolume);
  }

  void pauseMusic() {
    if (!_silent) FlameAudio.bgm.pause();
  }

  void resumeMusic() {
    if (!_silent) FlameAudio.bgm.resume();
  }

  void stopMusic() {
    if (!_silent) FlameAudio.bgm.stop();
  }

  /// Applies a volume or mute change to music that's already playing.
  void applySettings() {
    if (!_silent) FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
  }

  void play(String effect) {
    if (_silent || _sfxVolume == 0) return;
    FlameAudio.play(effect, volume: _sfxVolume);
  }

  void heavyHaptic() {
    if (!_silent && save.haptics) HapticFeedback.heavyImpact();
  }

  void lightHaptic() {
    if (!_silent && save.haptics) HapticFeedback.lightImpact();
  }
}
