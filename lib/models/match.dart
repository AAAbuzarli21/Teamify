import './team.dart';
import './balancing_mode.dart';

class Match {
  final String? id;
  final Team teamA;
  final Team teamB;
  final BalancingMode balancingMode;
  final int teamSize;
  final DateTime matchDate;

  // Optional features
  final int? scoreA;
  final int? scoreB;

  Match({
    this.id,
    required this.teamA,
    required this.teamB,
    required this.balancingMode,
    required this.teamSize,
    required this.matchDate,
    this.scoreA,
    this.scoreB,
  });

  factory Match.fromFirestore(Map<String, dynamic> firestore, String id) {
    return Match(
      id: id,
      teamA: Team.fromJson(firestore['teamA']),
      teamB: Team.fromJson(firestore['teamB']),
      balancingMode: BalancingMode.values.firstWhere((e) => e.toString() == 'BalancingMode.${firestore['balancingMode']}'),
      teamSize: firestore['teamSize'],
      matchDate: firestore['matchDate'].toDate(),
      scoreA: firestore['scoreA'],
      scoreB: firestore['scoreB'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamA': teamA.toJson(),
      'teamB': teamB.toJson(),
      'balancingMode': balancingMode.toString().split('.').last,
      'teamSize': teamSize,
      'matchDate': matchDate,
      'scoreA': scoreA,
      'scoreB': scoreB,
    };
  }
}
