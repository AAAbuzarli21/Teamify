import 'package:flutter/material.dart';
import 'package:myapp/models/balancing_mode.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../services/database_service.dart';
import '../widgets/player_card.dart';
import '../services/team_balancing_service.dart';
import 'team_balancing_screen.dart';
import '../widgets/gradient_background.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  TeamSelectionScreenState createState() => TeamSelectionScreenState();
}

class TeamSelectionScreenState extends State<TeamSelectionScreen> {
  List<Player> _allPlayers = [];
  final List<Player> _selectedPlayers = [];
  BalancingMode _balancingMode = BalancingMode.balanced;
  int _teamSize = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final players = await dbService.getPlayers().first;
    setState(() {
      _allPlayers = players;
    });
  }

  void _onPlayerSelected(Player player) {
    setState(() {
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
      } else {
        _selectedPlayers.add(player);
      }
    });
  }

  void _balanceTeams() {
    if (_selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 players.')),
      );
      return;
    }
    final balancer = TeamBalancingService();
    final result = balancer.createMatch(
      allPlayers: _selectedPlayers,
      mode: _balancingMode,
      teamSize: _teamSize,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamBalancingScreen(match: result),
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedPlayers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Team Balancer'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearSelection,
              tooltip: 'Clear Selection',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildControlPanel(),
            Expanded(child: _buildPlayerGrid()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _balanceTeams,
          icon: const Icon(Icons.balance),
          label: const Text('Balance Teams'),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Theme.of(context).cardColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonFormField<BalancingMode>(
              initialValue: _balancingMode,
              decoration: const InputDecoration(
                labelText: 'Balancing Mode',
                border: InputBorder.none,
              ),
              items: BalancingMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(_getIconForMode(mode),
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 10),
                      Text(mode.toString().split('.').last),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (mode) {
                if (mode != null) {
                  setState(() => _balancingMode = mode);
                }
              },
              dropdownColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 16),
          Text('Team Size: $_teamSize',
              style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _teamSize.toDouble(),
            min: 2,
            max: (_selectedPlayers.length / 2).clamp(2.0, 11.0),
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

  IconData _getIconForMode(BalancingMode mode) {
    switch (mode) {
      case BalancingMode.balanced:
        return Icons.star;
      case BalancingMode.random:
        return Icons.shuffle;
      case BalancingMode.byPosition:
        return Icons.pan_tool;
      }
  }

  Widget _buildPlayerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _allPlayers.length,
      itemBuilder: (context, index) {
        final player = _allPlayers[index];
        return PlayerCard(
          player: player,
          isSelected: _selectedPlayers.contains(player),
          onTap: () => _onPlayerSelected(player),
        );
      },
    );
  }
}
