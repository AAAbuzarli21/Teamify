import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../models/formation.dart';
import '../services/database_service.dart';
import '../widgets/player_icon.dart';
import '../theme/theme.dart';

class FormationScreen extends StatefulWidget {
  const FormationScreen({super.key});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  Formation? _currentFormation;
  List<Player> _availablePlayers = [];
  final Map<String, Offset> _playerPositions = {};
  final Map<String, Offset> _formationSlots = {};
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
      _formationSlots.clear();
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
            _formationSlots[playerSpot] = Offset(x, y);
          }
        }
      }
    });
  }

  void _saveFormation() async {
    if (_currentFormation == null) return;

    // 1. Get provider BEFORE async gaps
    final dbService = context.read<DatabaseService>();

    // 2. Ask the dialog (async)
    final newName = await _showSaveDialog();
    if (newName == null || newName.isEmpty) return;

    // 3. If widget unmounted after dialog → stop safely
    if (!mounted) return;

    // 4. Prepare players
    final Map<String, Player?> playersOnPitch = {};
    _playerPositions.forEach((playerId, offset) {
      playersOnPitch[playerId] =
          _availablePlayers.firstWhere((p) => p.id == playerId);
    });

    final benchPlayers = _availablePlayers
        .where((p) => !_playerPositions.containsKey(p.id))
        .toList();

    // 5. Save to database
    await dbService.saveFormation(
      formationName: newName,
      pitchPlayers: playersOnPitch,
      benchPlayers: benchPlayers,
    );

    // 6. Check mounted AGAIN before using context
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formation saved!')),
    );
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
            // ignore: deprecated_member_use
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
            border: Border.all(color: accentTurquoise, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: accentTurquoise.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              ..._formationSlots.entries.map((entry) {
                return Positioned(
                  left: entry.value.dx,
                  top: entry.value.dy,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),
              ..._playerPositions.entries.map((entry) {
                final player = _availablePlayers.firstWhere((p) => p.id == entry.key, orElse: () => Player(id: '', name: '', surname: '', attributes: PlayerAttributes(speed: 0, defense: 0, attack: 0, goalkeeper: 0), preferredPositions: []));
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
              }),
            ],
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
