import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../main.dart';

final supa = Supabase.instance.client;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ---------- MEALS ----------
  List<Map<String, dynamic>> todaysMeals = [];
  bool loadingMeals = true;

  // ---------- LOCKER ----------
  int? lockerNumber;
  bool loadingLocker = true;

  // ---------- UPCOMING CLASSES ----------
  List<Map<String, dynamic>> upcomingClasses = [];
  bool loadingClasses = true;

  // ---------- HISTORY ----------
  DateTime? lastVisit;
  List<DateTime> recentVisits = [];
  bool loadingHistory = true;

  @override
  void initState() {
    super.initState();
    fetchMeals();
    fetchLocker();
    fetchUpcomingClasses();
    fetchHistory();
  }

  // ================== FETCH MEALS ==================
  Future<void> fetchMeals() async {
    try {
      final user = supa.auth.currentUser;
      if (user == null) return;

      final response = await supa
          .from('todays_user_meals')
          .select('*')
          .eq('user_id', user.id);

      if (!mounted) return;
      setState(() {
        todaysMeals = response;
        loadingMeals = false;
      });
    } catch (e) {
      print("ERROR fetching meals: $e");
      loadingMeals = false;
    }
  }

  // ================== FETCH LOCKER ==================
  Future<void> fetchLocker() async {
    try {
      final user = supa.auth.currentUser;
      if (user == null) return;

      final response = await supa
          .from('locker_reservations')
          .select('locker_number')
          .eq('user_id', user.id)
          .order('id', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        lockerNumber = response[0]['locker_number'];
      }

      if (!mounted) return;
      setState(() => loadingLocker = false);
    } catch (e) {
      print("ERROR fetching locker: $e");
      loadingLocker = false;
    }
  }

  // ================== FETCH UPCOMING CLASSES ==================
  Future<void> fetchUpcomingClasses() async {
    try {
      final user = supa.auth.currentUser;
      if (user == null) return;

      // اليوم (بس التاريخ) بصيغة YYYY-MM-DD
      final today = DateTime.now().toUtc();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);

      final response = await supa
          .from('bookings')
          .select('''
            id,
            session:class_sessions (
              session_date,
              start_time,
              class:classes (
                title,
                trainer
              )
            )
          ''')
          .eq('user_id', user.id)
          .gte('class_sessions.session_date', todayStr)
          .order('class_sessions.session_date', ascending: true)
          .limit(3);

      final List data = response as List;

      final List<Map<String, dynamic>> mapped = data.map((row) {
        final session = row['session'] ?? {};
        final cls = session['class'] ?? {};
        return {
          'date': session['session_date'],
          'time': session['start_time'],
          'title': cls['title'],
          'trainer': cls['trainer'],
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        upcomingClasses = mapped;
        loadingClasses = false;
      });
    } catch (e) {
      print("ERROR fetching upcoming classes: $e");
      loadingClasses = false;
    }
  }

  // ================== FETCH HISTORY ==================
  Future<void> fetchHistory() async {
    try {
      final user = supa.auth.currentUser;
      if (user == null) return;

      final response = await supa
          .from('history')
          .select('created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      final List data = response as List;

      if (data.isNotEmpty) {
        lastVisit = DateTime.parse(data.first['created_at']);
      }

      recentVisits = data
          .map<DateTime>((row) => DateTime.parse(row['created_at']))
          .toList();

      if (!mounted) return;
      setState(() => loadingHistory = false);
    } catch (e) {
      print("ERROR fetching history: $e");
      loadingHistory = false;
    }
  }

  // ================== HELPERS ==================
  String formatDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return '';
    try {
      final dt = DateTime.parse('$dateStr $timeStr');
      return DateFormat('EEE, MMM d • hh:mm a').format(dt);
    } catch (_) {
      return '$dateStr $timeStr';
    }
  }

  String formatVisit(DateTime dt) {
    return DateFormat('yyyy-MM-dd • HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final user = supa.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ EMAIL ------------------
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ------------------ QR CODE ------------------
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: user?.id ?? "unknown-user",
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------ UPCOMING CLASSES ------------------
              const Text(
                "Upcoming Classes",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff1e1e1e),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: loadingClasses
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.pink))
                    : upcomingClasses.isEmpty
                        ? const Text(
                            "No upcoming classes booked.",
                            style: TextStyle(color: Colors.white70),
                          )
                        : Column(
                            children: upcomingClasses.map((cls) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.fitness_center,
                                        color: Colors.white70),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cls['title'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            cls['trainer'] != null
                                                ? "Trainer: ${cls['trainer']}"
                                                : "",
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            formatDateTime(
                                              cls['date']?.toString(),
                                              cls['time']?.toString(),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
              ),

              const SizedBox(height: 24),

              // ------------------ TODAY'S MEALS ------------------
              const Center(
                child: Text(
                  "Today's Meals",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff1e1e1e),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: loadingMeals
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.pink))
                    : todaysMeals.isEmpty
                        ? const Text(
                            "No meals selected for today.",
                            style: TextStyle(color: Colors.white70),
                          )
                        : Column(
                            children: todaysMeals.map((meal) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.restaurant_menu,
                                        color: Colors.white70),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            meal['part'] ?? "",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            meal['name'] ?? "",
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
              ),

              const SizedBox(height: 24),

              // ------------------ LOCKER ------------------
              const Text(
                "Locker",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff1e1e1e),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text(
                      loadingLocker
                          ? "Loading..."
                          : lockerNumber != null
                              ? "Locker Number: $lockerNumber"
                              : "Locker Number: —",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------ HISTORY ------------------
              const Text(
                "History",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff1e1e1e),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: loadingHistory
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.pink))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Last visit: ${lastVisit != null ? formatVisit(lastVisit!) : "—"}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 8),
                          const Text(
                            "Recent visits:",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (recentVisits.isEmpty)
                            const Text(
                              "No history yet.",
                              style:
                                  TextStyle(color: Colors.white60, fontSize: 13),
                            )
                          else
                            Column(
                              children: recentVisits.map((dt) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 16, color: Colors.white60),
                                      const SizedBox(width: 6),
                                      Text(
                                        formatVisit(dt),
                                        style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
