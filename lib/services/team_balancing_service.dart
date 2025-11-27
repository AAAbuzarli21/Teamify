import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/balancing_mode.dart';

class TeamBalancingService {
  Match createMatch(
      {required List<Player> allPlayers,
      required BalancingMode mode,
      required int teamSize}) {
    final players = List<Player>.from(allPlayers)..shuffle();
    List<Player> teamAPlayers = [];
    List<Player> teamBPlayers = [];

    switch (mode) {
      case BalancingMode.random:
        _randomBalancing(players, teamAPlayers, teamBPlayers, teamSize);
        break;
      case BalancingMode.balanced:
        _skillBasedBalancing(players, teamAPlayers, teamBPlayers, teamSize);
        break;
      case BalancingMode.byPosition:
        _positionalBalancing(players, teamAPlayers, teamBPlayers, teamSize);
        break;
    }

    final teamA =
        Team(name: 'Team A', color: Colors.blue, players: teamAPlayers);
    final teamB =
        Team(name: 'Team B', color: Colors.red, players: teamBPlayers);

    return Match(
      teamA: teamA,
      teamB: teamB,
      balancingMode: mode,
      teamSize: teamSize,
      matchDate: DateTime.now(),
    );
  }

  void _randomBalancing(List<Player> players, List<Player> teamA,
      List<Player> teamB, int teamSize) {
    final maxPlayers = teamSize * 2;
    final selectedPlayers = players.take(maxPlayers).toList();

    for (int i = 0; i < selectedPlayers.length; i++) {
      if (i.isEven) {
        teamA.add(selectedPlayers[i]);
      } else {
        teamB.add(selectedPlayers[i]);
      }
    }
  }

  void _skillBasedBalancing(List<Player> players, List<Player> teamA,
      List<Player> teamB, int teamSize) {
    final maxPlayers = teamSize * 2;
    final selectedPlayers = players.take(maxPlayers).toList();

    // Sort players by skill level
    selectedPlayers.sort(
        (a, b) => _calculateSkillScore(b).compareTo(_calculateSkillScore(a)));

    int teamASkill = 0;
    int teamBSkill = 0;

    for (final player in selectedPlayers) {
      if (teamASkill <= teamBSkill) {
        teamA.add(player);
        teamASkill += _calculateSkillScore(player);
      } else {
        teamB.add(player);
        teamBSkill += _calculateSkillScore(player);
      }
    }
  }

  void _positionalBalancing(List<Player> players, List<Player> teamA,
      List<Player> teamB, int teamSize) {
    final maxPlayers = teamSize * 2;
    final selectedPlayers = players.take(maxPlayers).toList();

    final goalkeepers = selectedPlayers
        .where((p) => p.preferredPositions.contains('GK'))
        .toList();
    final defenders = selectedPlayers
        .where((p) => p.preferredPositions.contains('DEF'))
        .toList();
    final midfielders = selectedPlayers
        .where((p) => p.preferredPositions.contains('MID'))
        .toList();
    final forwards = selectedPlayers
        .where((p) => p.preferredPositions.contains('FOR'))
        .toList();

    _distributePlayers(goalkeepers, teamA, teamB);
    _distributePlayers(defenders, teamA, teamB);
    _distributePlayers(midfielders, teamA, teamB);
    _distributePlayers(forwards, teamA, teamB);

    // Fill remaining spots
    final remainingPlayers = selectedPlayers
        .where((p) => !teamA.contains(p) && !teamB.contains(p))
        .toList();
    _distributePlayers(remainingPlayers, teamA, teamB);
  }

  void _distributePlayers(
      List<Player> players, List<Player> teamA, List<Player> teamB) {
    for (final player in players) {
      if (teamA.length <= teamB.length) {
        teamA.add(player);
      } else {
        teamB.add(player);
      }
    }
  }

  int _calculateSkillScore(Player player) {
    switch (player.skillLevel) {
      case SkillLevel.pro:
        return 3;
      case SkillLevel.intermediate:
        return 2;
      case SkillLevel.beginner:
        return 1;
    }
  }
}
