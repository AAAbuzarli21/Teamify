import 'dart:ui';

enum SkillLevel {
  beginner(Color(0xFFFFFF00)), // Light Yellow
  intermediate(Color(0xFFFFA500)), // Orange
  pro(Color(0xFFFFD700)); // Gold

  const SkillLevel(this.color);
  final Color color;
}

class Player {
  final String id;
  final String name;
  final String surname;
  final DateTime? birthDate;
  final String? sex;
  final int? jerseyNumber;
  final String? jerseyName;
  final String? favouriteTeam;
  final PlayerAttributes attributes;
  final List<String> preferredPositions;

  // Avatar customization
  final String hairStyle;
  final Color hairColor;
  final bool hasBeard;

  Player({
    required this.id,
    required this.name,
    required this.surname,
    this.birthDate,
    this.sex,
    this.jerseyNumber,
    this.jerseyName,
    this.favouriteTeam,
    required this.attributes,
    required this.preferredPositions,
    this.hairStyle = 'hair_1',
    this.hairColor = const Color(0xFF000000),
    this.hasBeard = false,
  });

  SkillLevel get skillLevel {
    final average = (attributes.speed + attributes.defense + attributes.attack + attributes.goalkeeper) / 4;
    if (average >= 80) {
      return SkillLevel.pro;
    } else if (average >= 50) {
      return SkillLevel.intermediate;
    } else {
      return SkillLevel.beginner;
    }
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      sex: json['sex'],
      jerseyNumber: json['jerseyNumber'],
      jerseyName: json['jerseyName'],
      favouriteTeam: json['favouriteTeam'],
      attributes: PlayerAttributes.fromJson(json['attributes']),
      preferredPositions: List<String>.from(json['preferredPositions']),
      hairStyle: json['hairStyle'] ?? 'hair_1',
      hairColor: json['hairColor'] != null ? Color(json['hairColor']) : const Color(0xFF000000),
      hasBeard: json['hasBeard'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'birthDate': birthDate?.toIso8601String(),
      'sex': sex,
      'jerseyNumber': jerseyNumber,
      'jerseyName': jerseyName,
      'favouriteTeam': favouriteTeam,
      'attributes': attributes.toJson(),
      'preferredPositions': preferredPositions,
      'hairStyle': hairStyle,
      // ignore: deprecated_member_use
      'hairColor': hairColor.value,
      'hasBeard': hasBeard,
    };
  }
}

class PlayerAttributes {
  final int speed;
  final int defense;
  final int attack;
  final int goalkeeper;

  PlayerAttributes({
    required this.speed,
    required this.defense,
    required this.attack,
    required this.goalkeeper,
  });

  factory PlayerAttributes.fromJson(Map<String, dynamic> json) {
    return PlayerAttributes(
      speed: json['speed'],
      defense: json['defense'],
      attack: json['attack'],
      goalkeeper: json['goalkeeper'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speed': speed,
      'defense': defense,
      'attack': attack,
      'goalkeeper': goalkeeper,
    };
  }
}
