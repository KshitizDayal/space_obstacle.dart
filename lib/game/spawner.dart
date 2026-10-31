import 'dart:math';

import 'package:flame/components.dart';
import 'package:space_obstacle/constants/game_audio.dart';
import 'package:space_obstacle/constants/game_color.dart';
import 'package:space_obstacle/constants/game_constants.dart';
import 'package:space_obstacle/constants/wave_event.dart';
import 'package:space_obstacle/game/main_game.dart';
import 'package:space_obstacle/sprites/black_hole.dart';
import 'package:space_obstacle/sprites/chaser.dart';
import 'package:space_obstacle/sprites/meteor.dart';
import 'package:space_obstacle/sprites/obstacles.dart';

/// Decides what comes at the player: obstacle columns that get faster and
/// tighter as the score climbs, and an event wave every few points.
class Spawner extends Component with HasGameReference<MainGame> {
  final _random = Random();

  double _columnCooldown = 0;
  int _nextEventScore = GameConstants.eventEveryScore;
  int _eventIndex = 0;
  WaveEvent? activeEvent;
  double _eventTimer = 0;
  double _eventSpawnCooldown = 0;
  BlackHole? _blackHole;

  double get scrollSpeed => min(
        GameConstants.gameSpeed + game.score * GameConstants.speedPerPoint,
        GameConstants.maxGameSpeed,
      );

  double get columnInterval => max(
        GameConstants.columnInterval -
            game.score * GameConstants.intervalPerPoint,
        GameConstants.minColumnInterval,
      );

  void reset() {
    _columnCooldown = 0;
    _nextEventScore = GameConstants.eventEveryScore;
    _eventIndex = 0;
    activeEvent = null;
    _blackHole = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.playing) return;

    if (activeEvent != null) {
      _updateEvent(dt);
    } else if (game.score >= _nextEventScore) {
      _startEvent();
    }

    // Columns pause during meteor and chaser waves, but keep coming during a black hole
    if (activeEvent == null || activeEvent == WaveEvent.blackHole) {
      _columnCooldown -= dt;
      if (_columnCooldown <= 0) {
        _spawnColumn();
        _columnCooldown = columnInterval;
      }
    }
  }

  void _spawnColumn() {
    final score = game.score;
    final oneGap = score >= GameConstants.oneGapFromScore && _random.nextBool();
    final movingChance = score < GameConstants.movingColumnsFromScore
        ? 0.0
        : min(
            GameConstants.maxMovingChance,
            (score - GameConstants.movingColumnsFromScore) * 0.02,
          );

    game.entities.add(Obstacles(
      emptySpots: oneGap ? 1 : GameConstants.emptySpots,
      moving: _random.nextDouble() < movingChance,
    ));
  }

  void _startEvent() {
    final event = WaveEvent.values[_eventIndex % WaveEvent.values.length];
    _eventIndex++;
    activeEvent = event;
    _eventTimer = GameConstants.eventDuration;
    _eventSpawnCooldown = 1.0;
    game.showBanner(event.title, color: GameColor.danger);
    game.feedback.play(GameAudio.alarm);

    if (event == WaveEvent.blackHole) {
      game.entities.add(_blackHole = BlackHole());
    }
  }

  void _updateEvent(double dt) {
    _eventTimer -= dt;
    if (_eventTimer <= 0) {
      _endEvent();
      return;
    }

    _eventSpawnCooldown -= dt;
    if (_eventSpawnCooldown > 0) return;

    switch (activeEvent!) {
      case WaveEvent.meteorShower:
        game.entities.add(Meteor());
        _eventSpawnCooldown = 0.35;
      case WaveEvent.chasers:
        game.entities.add(Chaser());
        _eventSpawnCooldown = 1.8;
      case WaveEvent.blackHole:
        break;
    }
  }

  void _endEvent() {
    _blackHole?.collapse();
    _blackHole = null;
    activeEvent = null;
    _columnCooldown = 0.5;
    _nextEventScore = game.score + GameConstants.eventEveryScore;

    game.addScore(GameConstants.eventSurviveBonus);
    game.showBanner(
      "SURVIVED! +${GameConstants.eventSurviveBonus}",
      color: GameColor.secondary,
    );
  }
}
