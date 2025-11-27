import 'package:flutter/material.dart';
import './player.dart';

class Team {
  final String name;
  final Color color;
  final List<Player> players;

  Team({
    required this.name,
    required this.color,
    required this.players,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      color: Color(json['color']),
      players: (json['players'] as List).map((playerJson) => Player.fromJson(playerJson)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.toARGB32(),
      'players': players.map((player) => player.toJson()).toList(),
    };
  }
}
