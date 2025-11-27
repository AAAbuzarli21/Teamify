import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

import 'services/database_service.dart';
import 'screens/roster_screen.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<DatabaseService>(
      create: (_) => DatabaseService(),
      child: MaterialApp(
        title: 'Team Manager',
        theme: AppTheme.darkTheme,
        home: const RosterScreen(),
      ),
    );
  }
}
