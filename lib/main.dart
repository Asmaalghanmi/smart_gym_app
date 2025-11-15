import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home.dart';
import 'screens/classes.dart';
import 'screens/meals.dart';
import 'screens/lockers.dart';
import 'screens/account.dart';
import 'screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const GoGymApp());
}

final supa = Supabase.instance.client;

class GoGymApp extends StatelessWidget {
  const GoGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9C7BFF),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF0E0E14),
        cardColor: const Color(0xFF1B1B25),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF16161F),
          selectedItemColor: Color(0xFFF48FB1),
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supa.auth.currentSession;
    return session == null ? LoginScreen() : const RootShell();
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    Home(), // dashboard
    ClassesScreen(), // booking
    MealsScreen(), // meals
    LockersScreen(), // lockers
  ];

  String _titleFor(int i) => switch (i) {
        0 => 'Home',
        1 => 'Classes',
        2 => 'Meals',
        3 => 'Lockers',
        _ => 'Go Gym',
      };

  @override
  Widget build(BuildContext context) {
    final maxIndex = _pages.length - 1;
    final safeIndex = _index.clamp(0, maxIndex);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(safeIndex)),
        backgroundColor: const Color(0xFF0E0E14),
        actions: [
          IconButton(
            tooltip: 'Account',
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[safeIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: 'Classes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded), label: 'Meals'),
          BottomNavigationBarItem(
              icon: Icon(Icons.lock_rounded), label: 'Lockers'),
        ],
      ),
    );
  }
}
