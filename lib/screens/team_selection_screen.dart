import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../services/database_service.dart';
import '../widgets/player_card.dart';
import '../theme/theme.dart';
import '../models/balancing_mode.dart';
import '../models/match.dart';
import '../services/team_balancing_service.dart';
import 'team_balancing_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final List<Player> _selectedPlayers = [];
  BalancingMode _balancingMode = BalancingMode.balanced;
  int _teamSize = 5;

  void _togglePlayerSelection(Player player) {
    setState(() {
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
      } else {
        _selectedPlayers.add(player);
      }
    });
  }

  void _navigateToBalancingScreen() {
    if (_selectedPlayers.length < _teamSize * 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least ${_teamSize * 2} players.')),
      );
      return;
    }

    final balancingService = TeamBalancingService();
    final match = balancingService.createMatch(
      _selectedPlayers,
      _balancingMode,
      _teamSize,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamBalancingScreen(match: match),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Players', style: theme.textTheme.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToBalancingScreen,
            tooltip: 'Next',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: StreamBuilder<List<Player>>(
              stream: dbService.getPlayers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final players = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isSelected = _selectedPlayers.contains(player);
                    return GestureDetector(
                      onTap: () => _togglePlayerSelection(player),
                      child: Opacity(
                        opacity: isSelected ? 1.0 : 0.6,
                        child: PlayerCard(player: player, isSelected: isSelected),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<BalancingMode>(
            value: _balancingMode,
            decoration: const InputDecoration(labelText: 'Balancing Mode'),
            items: BalancingMode.values
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode.toString().split('.').last)))
                .toList(),
            onChanged: (mode) {
              if (mode != null) {
                setState(() => _balancingMode = mode);
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Team Size: $_teamSize'),
          Slider(
            value: _teamSize.toDouble(),
            min: 2,
            max: 11,
            divisions: 9,
            label: _teamSize.toString(),
            onChanged: (value) {
              setState(() {
                _teamSize = value.round();
              });
            },
          ),
        ],
      ),
    );
  }
}
