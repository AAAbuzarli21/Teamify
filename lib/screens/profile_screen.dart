import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../widgets/customizable_avatar.dart';
import '../widgets/player_card.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final DatabaseService _dbService;

  // Form fields
  String _name = '';
  String _surname = '';
  DateTime? _birthDate;
  String? _sex;
  int? _jerseyNumber;
  String? _jerseyName;
  String? _favouriteTeam;
  int _speed = 50;
  int _defense = 50;
  int _attack = 50;
  int _goalkeeper = 50;
  List<String> _preferredPositions = [];

  // Avatar customization
  String _hairStyle = 'hair_1';
  Color _hairColor = const Color(0xFF000000);
  bool _hasBeard = false;

  final List<String> _positions = ['GK', 'DEF', 'MID', 'FOR'];
  final List<String> _hairStyles = ['hair_1', 'hair_2', 'hair_3'];

  @override
  void initState() {
    super.initState();
    _dbService = Provider.of<DatabaseService>(context, listen: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final playerData = await _dbService.getPlayer(user.uid);
      if (playerData != null) {
        setState(() {
          _name = playerData.name;
          _surname = playerData.surname;
          _birthDate = playerData.birthDate;
          _sex = playerData.sex;
          _jerseyNumber = playerData.jerseyNumber;
          _jerseyName = playerData.jerseyName;
          _favouriteTeam = playerData.favouriteTeam;
          _speed = playerData.attributes.speed;
          _defense = playerData.attributes.defense;
          _attack = playerData.attributes.attack;
          _goalkeeper = playerData.attributes.goalkeeper;
          _preferredPositions = playerData.preferredPositions;
          _hairStyle = playerData.hairStyle;
          _hairColor = playerData.hairColor;
          _hasBeard = playerData.hasBeard;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final playerToSave = Player(
        id: user.uid,
        name: _name,
        surname: _surname,
        birthDate: _birthDate,
        sex: _sex,
        jerseyNumber: _jerseyNumber,
        jerseyName: _jerseyName,
        favouriteTeam: _favouriteTeam,
        attributes: PlayerAttributes(
          speed: _speed,
          defense: _defense,
          attack: _attack,
          goalkeeper: _goalkeeper,
        ),
        preferredPositions: _preferredPositions,
        hairStyle: _hairStyle,
        hairColor: _hairColor,
        hasBeard: _hasBeard,
      );

      try {
        await _dbService.savePlayer(playerToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewPlayer = Player(
      id: FirebaseAuth.instance.currentUser?.uid ?? 'temp-id',
      name: _name,
      surname: _surname,
      birthDate: _birthDate,
      sex: _sex,
      jerseyNumber: _jerseyNumber,
      jerseyName: _jerseyName,
      favouriteTeam: _favouriteTeam,
      attributes: PlayerAttributes(
        speed: _speed,
        defense: _defense,
        attack: _attack,
        goalkeeper: _goalkeeper,
      ),
      preferredPositions: _preferredPositions,
      hairStyle: _hairStyle,
      hairColor: _hairColor,
      hasBeard: _hasBeard,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: CustomizableAvatar(
                      hairStyle: _hairStyle,
                      hairColor: _hairColor,
                      hasBeard: _hasBeard,
                      radius: 50,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildAvatarControls(),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    initialValue: _name,
                    onSaved: (value) => _name = value!,
                    onChanged: (value) => setState(() => _name = value),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Surname'),
                    validator: (value) => value!.isEmpty ? 'Please enter your surname' : null,
                    initialValue: _surname,
                    onSaved: (value) => _surname = value!,
                    onChanged: (value) => setState(() => _surname = value),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Birth Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    controller: TextEditingController(
                      text: _birthDate == null ? '' : DateFormat.yMd().format(_birthDate!),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Sex'),
                    initialValue: _sex,
                    items: ['Male', 'Female', 'Other']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sex = value);
                      }
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Jersey Number',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _jerseyNumber != null ? _jerseyNumber.toString() : '',
                    onChanged: (value) {
                      final number = int.tryParse(value);
                      setState(() => _jerseyNumber = number);
                    },
                    onSaved: (value) {
                      _jerseyNumber = int.tryParse(value ?? '');
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Jersey Name'),
                    initialValue: _jerseyName,
                    onSaved: (value) => _jerseyName = value,
                    onChanged: (value) => setState(() => _jerseyName = value),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Favourite Team'),
                    initialValue: _favouriteTeam,
                    onSaved: (value) => _favouriteTeam = value,
                    onChanged: (value) => setState(() => _favouriteTeam = value),
                  ),
                  const SizedBox(height: 16.0),
                  Text('Attributes', style: Theme.of(context).textTheme.titleLarge),
                  _buildSlider('Speed', _speed.toDouble(), (val) => setState(() => _speed = val.round())),
                  _buildSlider('Defense', _defense.toDouble(), (val) => setState(() => _defense = val.round())),
                  _buildSlider('Attack', _attack.toDouble(), (val) => setState(() => _attack = val.round())),
                  _buildSlider('Goalkeeper', _goalkeeper.toDouble(), (val) => setState(() => _goalkeeper = val.round())),
                  const SizedBox(height: 16.0),
                  MultiSelectDialogField(
                    items: _positions.map((e) => MultiSelectItem(e, e)).toList(),
                    title: const Text('Preferred Positions'),
                    selectedColor: Theme.of(context).primaryColor,
                    buttonText: const Text('Preferred Positions'),
                    initialValue: _preferredPositions,
                    onConfirm: (values) {
                      setState(() {
                        _preferredPositions = values.cast<String>();
                      });
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      onTap: (value) {
                        setState(() {
                          _preferredPositions.remove(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Text('Player Card Preview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16.0),
            SizedBox(width: 300, child: PlayerCard(player: previewPlayer)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton<String>(
              value: _hairStyle,
              items: _hairStyles
                  .map((style) => DropdownMenuItem(value: style, child: Text(style.replaceAll('_', ' ').toUpperCase())))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _hairStyle = value);
                }
              },
            ),
            ElevatedButton(onPressed: _pickHairColor, child: const Text('Hair Color')),
          ],
        ),
        SwitchListTile(
          title: const Text('Beard'),
          value: _hasBeard,
          onChanged: (value) => setState(() => _hasBeard = value),
        ),
      ],
    );
  }

  void _pickHairColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _hairColor,
            onColorChanged: (color) => setState(() => _hairColor = color),
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}'),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
