import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../services/database_service.dart';
import '../widgets/player_card.dart';
import '../screens/player_edit_screen.dart';
import '../screens/team_selection_screen.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Player Roster', style: theme.textTheme.headlineLarge),
      ),
      body: StreamBuilder<List<Player>>(
        stream: dbService.getPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No players yet. Tap \'+\' to add your first player!',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final players = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Adjust number of columns
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75, // Adjust aspect ratio for card size
            ),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PlayerEditScreen(player: player)),
                ),
                child: PlayerCard(player: player),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlayerEditScreen()),
        ),
        child: const Icon(Icons.add),
      ),
       bottomNavigationBar: BottomAppBar(
        color: theme.appBarTheme.backgroundColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TeamSelectionScreen()),
            ),
            icon: const Icon(Icons.group_add, size: 28),
            label: Text('Create a Match', style: theme.textTheme.labelLarge?.copyWith(fontSize: 18)),
            style: theme.elevatedButtonTheme.style?.copyWith(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ),
      ),
    );
  }
}
