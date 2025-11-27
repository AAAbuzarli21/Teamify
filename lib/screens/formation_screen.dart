import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../models/formation.dart';
import '../services/database_service.dart';
import '../widgets/player_icon.dart';

class FormationScreen extends StatefulWidget {
  const FormationScreen({super.key});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  Formation? _currentFormation;
  List<Player> _availablePlayers = [];
  final Map<String, Offset> _playerPositions = {};
  final GlobalKey _pitchKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final players = await dbService.getPlayers().first;
    setState(() {
      _availablePlayers = players;
    });
  }

  void _onFormationSelected(Formation formation) {
    setState(() {
      _currentFormation = formation;
      _playerPositions.clear();
      final pitchSize = _pitchKey.currentContext?.size ?? const Size(400, 600);
      final rows = formation.layout.length;
      for (int i = 0; i < rows; i++) {
        final playersInRow = formation.layout[i];
        final rowCount = playersInRow.length;
        for (int j = 0; j < rowCount; j++) {
          final playerSpot = playersInRow[j];
          if (playerSpot.isNotEmpty) {
            final x = (pitchSize.width / (rowCount + 1)) * (j + 1);
            final y = (pitchSize.height / (rows + 1)) * (i + 1);
            _playerPositions[playerSpot] = Offset(x, y);
          }
        }
      }
    });
  }

  void _saveFormation() async {
    if (_currentFormation == null) return;

    final newName = await _showSaveDialog();
    if (newName != null && newName.isNotEmpty) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final formationToSave = Formation(
        id: _currentFormation!.id, // Preserve ID for updates
        name: newName,
        layout: _currentFormation!.layout, // Or update the layout based on _playerPositions
      );
      await dbService.saveFormation(formationToSave);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formation saved!')),
      );
    }
  }

  Future<String?> _showSaveDialog() {
    final TextEditingController controller = TextEditingController(text: _currentFormation?.name);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Formation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Formation Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tactical Board', style: theme.textTheme.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFormation,
            tooltip: 'Save Formation',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFormationSelector(),
          Expanded(
            child: _buildPitch(),
          ),
          _buildPlayerBench(),
        ],
      ),
    );
  }

  Widget _buildFormationSelector() {
    final dbService = Provider.of<DatabaseService>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<Formation>>(
        stream: dbService.getFormations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final formations = snapshot.data!;
          return DropdownButtonFormField<Formation>(
            value: _currentFormation,
            hint: const Text('Select a Formation'),
            onChanged: (formation) {
              if (formation != null) {
                _onFormationSelected(formation);
              }
            },
            items: formations.map((f) => DropdownMenuItem(value: f, child: Text(f.name))).toList(),
            decoration: const InputDecoration(labelText: 'Formation'),
          );
        },
      ),
    );
  }

  Widget _buildPitch() {
    return DragTarget<Player>(
      onAcceptWithDetails: (details) {
        final RenderBox pitchBox = _pitchKey.currentContext!.findRenderObject() as RenderBox;
        final localOffset = pitchBox.globalToLocal(details.offset);
        setState(() {
          _playerPositions[details.data.id] = localOffset;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          key: _pitchKey,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[800],
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: _playerPositions.entries.map((entry) {
              final player = _availablePlayers.firstWhere((p) => p.id == entry.key, orElse: () => Player(id: '', name: '', surname: '', skillLevel: SkillLevel.beginner, attributes: PlayerAttributes(attack: 0, defense: 0, speed: 0, goalkeeper: 0), preferredPositions: []));
              if (player.id.isEmpty) return const SizedBox.shrink();

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                left: entry.value.dx,
                top: entry.value.dy,
                child: Draggable<Player>(
                  data: player,
                  feedback: PlayerIcon(player: player, size: 55),
                  childWhenDragging: Opacity(opacity: 0.5, child: PlayerIcon(player: player)),
                  onDragEnd: (details) {
                     final RenderBox pitchBox = _pitchKey.currentContext!.findRenderObject() as RenderBox;
                     final localOffset = pitchBox.globalToLocal(details.offset);
                     setState(() {
                       _playerPositions[player.id] = localOffset;
                     });
                  },
                  child: PlayerIcon(player: player),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPlayerBench() {
    // Players not yet on the pitch
    final benchedPlayers = _availablePlayers.where((p) => !_playerPositions.containsKey(p.id)).toList();

    return Container(
      height: 90,
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: benchedPlayers.length,
        itemBuilder: (context, index) {
          final player = benchedPlayers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Draggable<Player>(
              data: player,
              feedback: PlayerIcon(player: player, size: 60),
              childWhenDragging: Opacity(opacity: 0.4, child: PlayerIcon(player: player)),
              child: PlayerIcon(player: player),
            ),
          );
        },
      ),
    );
  }
}
