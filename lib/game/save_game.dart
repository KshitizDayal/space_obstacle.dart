import 'package:shared_preferences/shared_preferences.dart';

/// Everything that survives an app restart: the high score and the player's settings.
class SaveGame {
  static const _highScoreKey = "highScore";
  static const _mutedKey = "muted";
  static const _musicVolumeKey = "musicVolume";
  static const _sfxVolumeKey = "sfxVolume";
  static const _hapticsKey = "haptics";

  final SharedPreferences _prefs;

  SaveGame._(this._prefs);

  static Future<SaveGame> load() async =>
      SaveGame._(await SharedPreferences.getInstance());

  // SharedPreferences updates its in-memory copy straight away, so the
  // setters don't need to be awaited for the new value to be read back.

  int get highScore => _prefs.getInt(_highScoreKey) ?? 0;
  set highScore(int value) => _prefs.setInt(_highScoreKey, value);

  bool get muted => _prefs.getBool(_mutedKey) ?? false;
  set muted(bool value) => _prefs.setBool(_mutedKey, value);

  double get musicVolume => _prefs.getDouble(_musicVolumeKey) ?? 0.5;
  set musicVolume(double value) => _prefs.setDouble(_musicVolumeKey, value);

  double get sfxVolume => _prefs.getDouble(_sfxVolumeKey) ?? 0.8;
  set sfxVolume(double value) => _prefs.setDouble(_sfxVolumeKey, value);

  bool get haptics => _prefs.getBool(_hapticsKey) ?? true;
  set haptics(bool value) => _prefs.setBool(_hapticsKey, value);
}
