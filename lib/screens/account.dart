import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';
import 'renew_screen.dart';

final supa = Supabase.instance.client;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int classCount = 0;
  int mealCount = 0;
  int visitCount = 0;
  String lastCheckIn = "-";

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final user = supa.auth.currentUser;
    if (user == null) return;

    try {
      final userId = user.id;

      final bookings =
          await supa.from('bookings').select('*').eq('user_id', userId);
      final meals =
          await supa.from('meal_reservations').select('*').eq('user_id', userId);
      final history = await supa
          .from('history')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        classCount = bookings.length;
        mealCount = meals.length;
        visitCount = history.length;
        if (history.isNotEmpty) {
          lastCheckIn = history.first['created_at'].toString().split('.')[0];
        }
      });
    } catch (e) {
      debugPrint("⚠️ Error loading stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supa.auth.currentUser;

    final String userName = user?.email?.split('@')[0] ?? "User";
    final String userEmail = user?.email ?? "email@example.com";

    final String membershipPlan = "Premium (6 Months)";
    final String membershipStatus = "Active";
    final String expiryDate = "2026-02-22";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "Account",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchStats,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundImage: NetworkImage(
                        "https://randomuser.me/api/portraits/women/44.jpg"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Card(
              color: const Color(0xFF181820),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.card_membership, color: Colors.pink[300]),
                title: const Text(
                  "Membership Plan",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "$membershipPlan\nStatus: $membershipStatus\nExpires: $expiryDate",
                  style: const TextStyle(color: Colors.white70),
                ),
                isThreeLine: true,
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionPage()),
                    );
                  },
                  child: const Text("Renew"),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoTile("Classes", classCount, Icons.fitness_center),
                _infoTile("Meals", mealCount, Icons.restaurant_menu),
                _infoTile("Visits", visitCount, Icons.history),
              ],
            ),

            const SizedBox(height: 26),

            Card(
              color: const Color(0xFF181820),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.login, color: Colors.blue[200]),
                    title: const Text(
                      "Last Check-In",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      lastCheckIn,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 1),

                  ListTile(
                    leading:
                        const Icon(Icons.exit_to_app, color: Colors.redAccent),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      try {
                        await supa.auth.signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Logout error: $e")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, int value, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.pink[100],
          child: Icon(icon, color: Colors.pink[400]),
        ),
        const SizedBox(height: 6),
        Text(
          "$value",
          style:
              const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
