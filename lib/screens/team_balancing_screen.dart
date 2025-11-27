import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/database_service.dart';
import '../services/team_balancing_service.dart';
import '../widgets/player_card.dart';
import '../theme/theme.dart';

class TeamBalancingScreen extends StatefulWidget {
  final Match match;

  const TeamBalancingScreen({super.key, required this.match});

  @override
  State<TeamBalancingScreen> createState() => _TeamBalancingScreenState();
}

class _TeamBalancingScreenState extends State<TeamBalancingScreen> with TickerProviderStateMixin {
  late Match _currentMatch;
  late AnimationController _shuffleController;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
    _shuffleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    super.dispose();
  }

  void _shuffleTeams() {
    final balancingService = TeamBalancingService();
    final allPlayers = [..._currentMatch.teamA.players, ..._currentMatch.teamB.players];
    setState(() {
      _currentMatch = balancingService.createMatch(
        allPlayers: allPlayers,
        mode: _currentMatch.balancingMode,
        teamSize: _currentMatch.teamA.players.length, // or teamB, they are the same size
      );
    });
    _shuffleController.forward(from: 0.0);
  }

  void _saveMatch() {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    dbService.addMatch(_currentMatch);
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Teams', style: theme.textTheme.headlineLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildTeamColumn(theme, 'Team A', _currentMatch.teamA.players, accentTurquoise),
                  _buildTeamColumn(theme, 'Team B', _currentMatch.teamB.players, accentOrange),
                ],
              ),
            ),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamColumn(ThemeData theme, String title, List<Player> players, Color teamColor) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: theme.textTheme.headlineLarge?.copyWith(color: teamColor, fontSize: 28)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _shuffleController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * (1 - _shuffleController.value)),
                      child: child,
                    );
                  },
                  child: PlayerCard(player: players[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _shuffleTeams,
            icon: const Icon(Icons.shuffle, size: 28),
            label: Text('Shuffle', style: theme.textTheme.labelLarge?.copyWith(fontSize: 20)),
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(accentNeonGreen),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _saveMatch,
            icon: const Icon(Icons.save, size: 28),
            label: Text('Save Match', style: theme.textTheme.labelLarge?.copyWith(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
