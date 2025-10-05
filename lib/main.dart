import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/classes.dart';
import 'screens/account.dart';

void main() => runApp(const GoGymApp());

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
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final _pages = const [HomeScreen(), ClassesScreen(), AccountScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
        ],
      ),
    );
  }
}
