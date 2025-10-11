import 'package:flutter/material.dart';
import 'package:mys_app/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home.dart';
import 'screens/classes.dart';
import 'screens/account.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ اربطي المشروع بقاعدة Supabase (استبدلي القيم لو مشروع ثاني)
  await Supabase.initialize(
    url: 'https://ypwulvcsaeyagluczvwr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlwd3VsdmNzYWV5YWdsdWN6dndyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5MTU1NDAsImV4cCI6MjA3NTQ5MTU0MH0.X5co-yU3dZ2j2v6neriRF9ewvfsphRZKr3abscJlupU',
  );

  runApp(const GoGymApp());
}

// 🌟 تقدروا تستخدمون هذا العميل بأي شاشة: supa.from('table')...
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
      home: const LoginPage(),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: 'Classes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Account'),
        ],
      ),
    );
  }
}
