import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/player.dart';
import '../models/match.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Formations
  Future<void> saveFormation({
    required String formationName,
    required Map<String, Player?> pitchPlayers,
    required List<Player> benchPlayers,
  }) async {
    if (currentUser == null) return;
    final formationData = {
      'name': formationName,
      'pitchPlayers': pitchPlayers.map((key, value) => MapEntry(key, value?.toJson())),
      'benchPlayers': benchPlayers.map((player) => player.toJson()).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(currentUser!.uid).collection('formations').add(formationData);
  }

  Future<List<Map<String, dynamic>>> loadFormations() async {
    if (currentUser == null) return [];
    final snapshot = await _db.collection('users').doc(currentUser!.uid).collection('formations').orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> deleteFormation(String formationId) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).collection('formations').doc(formationId).delete();
  }

  // Roster and Player Management
  Stream<List<Player>> getPlayers() {
    if (currentUser == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('roster')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Player.fromJson(doc.data())).toList());
  }

  Future<Player?> getPlayer(String playerId) async {
    if (currentUser == null) return null;
    final doc = await _db.collection('users').doc(currentUser!.uid).collection('roster').doc(playerId).get();
    if (doc.exists && doc.data() != null) {
      return Player.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> addPlayer(Player player) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).collection('roster').doc(player.id).set(player.toJson());
  }
  
  Future<void> savePlayer(Player player) async {
    // This method is an alias for addPlayer, but provides semantic clarity for saving the user's profile.
    await addPlayer(player);
  }

  Future<void> updatePlayer(Player player) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).collection('roster').doc(player.id).update(player.toJson());
  }

  Future<void> deletePlayer(String playerId) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).collection('roster').doc(playerId).delete();
  }

  // Match Management
  Stream<List<Match>> getMatches() {
    if (currentUser == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('matches')
        .orderBy('matchDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Match.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> addMatch(Match match) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).collection('matches').add(match.toMap());
  }

  Future<void> updateMatch(Match match) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).collection('matches').doc(match.id).update(match.toMap());
  }

  Future<void> deleteMatch(String matchId) async {
    if (currentUser == null) return;
    await _db.collection('users').doc(currentUser!.uid).collection('matches').doc(matchId).delete();
  }
}
