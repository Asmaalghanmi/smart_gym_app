import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home.dart';
import 'screens/classes.dart';
import 'screens/account.dart';
import 'screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تحميل ملف .env
  await dotenv.load(fileName: ".env");

  // ✅ تهيئة Supabase باستخدام القيم من ملف .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  print('✅ Supabase connected: ${dotenv.env['SUPABASE_URL']}');

  runApp(const GoGymApp());
}

// 🌟 العميل الجاهز لأي شاشة
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

// ✅ يحدد هل المستخدم مسجل دخول أو لا
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return LoginScreen(); // بدون const لتفادي الخطأ
    } else {
      return const RootShell();
    }
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  // ✅ الصفحات الأساسية
  final _pages = const [
    HomeScreen(),
    ClassesScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: 'Classes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Account'),
        ],
      ),
    );
  }
}
