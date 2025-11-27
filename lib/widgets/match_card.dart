import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../theme/theme.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match on ${DateFormat.yMMMd().format(match.matchDate)}',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTeamSummary(theme, 'Team A', match.teamA.players.length, accentTurquoise),
                const Text('VS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentOrange)),
                _buildTeamSummary(theme, 'Team B', match.teamB.players.length, accentOrange),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Mode: ${match.balancingMode.toString().split('.').last}',
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSummary(ThemeData theme, String teamName, int playerCount, Color color) {
    return Column(
      children: [
        Text(
          teamName,
          style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('$playerCount players', style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
