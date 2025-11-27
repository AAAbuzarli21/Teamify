import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class PlayerEditScreen extends StatefulWidget {
  final Player? player;

  const PlayerEditScreen({super.key, this.player});

  @override
  State<PlayerEditScreen> createState() => _PlayerEditScreenState();
}

class _PlayerEditScreenState extends State<PlayerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();

  late String _name;
  late String _surname;
  DateTime? _birthDate;
  String? _sex;
  int? _jerseyNumber;
  String? _jerseyName;
  String? _favouriteTeam;
  late int _speed;
  late int _defense;
  late int _attack;
  late int _goalkeeper;
  List<String> _preferredPositions = [];

  @override
  void initState() {
    super.initState();
    _name = widget.player?.name ?? '';
    _surname = widget.player?.surname ?? '';
    _birthDate = widget.player?.birthDate;
    _sex = widget.player?.sex;
    _jerseyNumber = widget.player?.jerseyNumber;
    _jerseyName = widget.player?.jerseyName;
    _favouriteTeam = widget.player?.favouriteTeam;
    _speed = widget.player?.attributes.speed ?? 50;
    _defense = widget.player?.attributes.defense ?? 50;
    _attack = widget.player?.attributes.attack ?? 50;
    _goalkeeper = widget.player?.attributes.goalkeeper ?? 50;
    _preferredPositions = widget.player?.preferredPositions ?? [];
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1950), 
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  void _savePlayer() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final attributes = PlayerAttributes(
        speed: _speed,
        defense: _defense,
        attack: _attack,
        goalkeeper: _goalkeeper,
      );

      final player = Player(
        id: widget.player?.id ?? DateTime.now().toIso8601String(), // Simple unique ID
        name: _name,
        surname: _surname,
        birthDate: _birthDate,
        sex: _sex,
        jerseyNumber: _jerseyNumber,
        jerseyName: _jerseyName,
        favouriteTeam: _favouriteTeam,
        attributes: attributes,
        preferredPositions: _preferredPositions,
      );

      if (widget.player == null) {
        _dbService.addPlayer(player);
      } else {
        _dbService.updatePlayer(player);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player == null ? 'Add Player' : 'Edit Player'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _savePlayer),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(initialValue: _name, decoration: const InputDecoration(labelText: 'Name'), onSaved: (v) => _name = v!), 
              TextFormField(initialValue: _surname, decoration: const InputDecoration(labelText: 'Surname'), onSaved: (v) => _surname = v!), 
              ListTile(
                title: Text(_birthDate == null ? 'Select Birth Date' : DateFormat.yMMMd().format(_birthDate!)),
                trailing: const Icon(Icons.calendar_today), 
                onTap: _selectDate,
              ),
              DropdownButtonFormField<String>(
                initialValue: _sex, 
                items: ['Male', 'Female'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _sex = v),
                decoration: const InputDecoration(labelText: 'Sex'),
              ),
              TextFormField(initialValue: _jerseyNumber?.toString(), decoration: const InputDecoration(labelText: 'Jersey Number'), keyboardType: TextInputType.number, onSaved: (v) => _jerseyNumber = int.tryParse(v!)),
              TextFormField(initialValue: _jerseyName, decoration: const InputDecoration(labelText: 'Jersey Name'), onSaved: (v) => _jerseyName = v),
              TextFormField(initialValue: _favouriteTeam, decoration: const InputDecoration(labelText: 'Favourite Team'), onSaved: (v) => _favouriteTeam = v), 
              const SizedBox(height: 20),
              const Text('Player Attributes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildAttributeSlider('Speed', _speed, (v) => setState(() => _speed = v.round())),
              _buildAttributeSlider('Defense', _defense, (v) => setState(() => _defense = v.round())),
              _buildAttributeSlider('Attack', _attack, (v) => setState(() => _attack = v.round())),
              _buildAttributeSlider('Goalkeeper', _goalkeeper, (v) => setState(() => _goalkeeper = v.round())),
              const SizedBox(height: 20),
              const Text('Preferred Positions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildPositionChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeSlider(String label, int value, ValueChanged<double> onChanged) {
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 16)),
      Expanded(child: Slider(value: value.toDouble(), min: 0, max: 100, divisions: 100, label: value.toString(), onChanged: onChanged)),
      Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildPositionChips() {
    final positions = ['GK', 'DEF', 'MID', 'FOR'];
    return Wrap(
      spacing: 8.0,
      children: positions.map((pos) => ChoiceChip(
        label: Text(pos),
        selected: _preferredPositions.contains(pos),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _preferredPositions.add(pos);
            } else {
              _preferredPositions.remove(pos);
            }
          });
        },
      )).toList(),
    );
  }
}
