import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/theme.dart';

class PlayerIcon extends StatelessWidget {
  final Player player;
  final double size;

  const PlayerIcon({super.key, required this.player, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentDeepBlue.withAlpha(204), // 80% opacity
        border: Border.all(color: accentTurquoise, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentTurquoise.withAlpha(128), // 50% opacity
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          player.jerseyNumber?.toString() ?? player.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
