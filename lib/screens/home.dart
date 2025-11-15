import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

final supa = Supabase.instance.client;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> todaysMeals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  Future<void> fetchMeals() async {
    try {
      final user = supa.auth.currentUser;

      if (user == null) {
        setState(() => loading = false);
        return;
      }

      final response = await supa
          .from('todays_user_meals')
          .select('*')
          .eq('user_id', user.id);

      setState(() {
        todaysMeals = response;
        loading = false;
      });
    } catch (e) {
      print("ERROR fetching meals: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = supa.auth.currentUser;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    user?.email ?? "email@example.com",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ------------------ TODAY MEALS TITLE ------------------
              Center(
                child: Text(
                  "Today's Meals",
                  style: theme.textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 20),

              // ------------------ MEALS CARD ------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.pink))
                    : todaysMeals.isEmpty
                        ? const Text(
                            "No meals selected for today.",
                            style: TextStyle(color: Colors.white70),
                          )
                        : Column(
                            children: todaysMeals
                                .map((meal) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  meal['name'] ?? "",
                                                  style: const TextStyle(
                                                      color: Colors.white70),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
              ),

              const SizedBox(height: 30),

              // ------------------ LOCKER BOX ------------------
              Text("Locker", style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text("Locker Number: —", style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
