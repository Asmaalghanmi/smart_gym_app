import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ypwulvcsaeyagluczvwr.supabase.co',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),
      home: const MealsScreen(),
    );
  }
}

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final supabase = Supabase.instance.client;
  DateTime _selectedDay = DateTime.now();
  final List<String> _parts = ['Breakfast', 'Lunch', 'Dinner'];
  int _partIndex = 0;
  List<Map<String, dynamic>> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final response = await supabase.from('meals').select();
    setState(() => _meals = List<Map<String, dynamic>>.from(response));
  }

  DateTime get _startOfWeek {
    final now = _selectedDay;
    final diff = now.weekday - DateTime.monday;
    return now.subtract(Duration(days: diff < 0 ? 6 : diff));
  }

  List<DateTime> get _weekDays {
    final start = _startOfWeek;
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  Future<void> bookMeal(String mealId) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please log in first"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    final day = _selectedDay.toIso8601String().split('T').first;
    final currentPart = _parts[_partIndex];

    try {
      final existing = await supabase
          .from('meal_reservations')
          .select('id, meals(part)')
          .eq('user_id', user.id)
          .eq('day', day);

      bool alreadyBookedSamePart = false;

      for (final record in existing) {
        final meal = record['meals'];
        if (meal != null && meal['part'] == currentPart) {
          alreadyBookedSamePart = true;
          break;
        }
      }

      if (alreadyBookedSamePart) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("⚠️ You already booked a $currentPart meal for this day"),
          backgroundColor: Colors.orangeAccent.shade700,
        ));
        return;
      }

      await supabase.from('meal_reservations').insert({
        'user_id': user.id,
        'meal_id': mealId,
        'day': day,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Meal booked successfully ✅"),
        backgroundColor: Colors.greenAccent.shade700,
      ));
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Error: ${e.message}"),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMeals =
        _meals.where((m) => m['part'] == _parts[_partIndex]).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text("My Meals",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookedMealsScreen()),
              );
            },
            child: const Text(
              "VIEW",
              style: TextStyle(
                  color: Colors.pinkAccent, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: _meals.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 75,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _weekDays.length,
                    itemBuilder: (ctx, i) {
                      final d = _weekDays[i];
                      final now = DateTime.now();
                      final active = d.day == _selectedDay.day &&
                          d.month == _selectedDay.month;
                      final isToday = d.day == now.day &&
                          d.month == now.month &&
                          d.year == now.year;
                      final isPast =
                          d.isBefore(DateTime(now.year, now.month, now.day));

                      return GestureDetector(
                        onTap: () {
                          if (isPast) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("🚫 You can’t book meals for past days"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          } else {
                            setState(() => _selectedDay = d);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.pinkAccent
                                : isPast
                                    ? Colors.grey.shade900.withOpacity(.4)
                                    : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: active
                                  ? Colors.pinkAccent
                                  : isPast
                                      ? Colors.grey.withOpacity(.3)
                                      : Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _monthAbbr(d.month),
                                  style: TextStyle(
                                    color: isPast
                                        ? Colors.white.withOpacity(.35)
                                        : Colors.white.withOpacity(.7),
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  d.day.toString(),
                                  style: TextStyle(
                                    color: isPast
                                        ? Colors.white.withOpacity(.4)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isToday)
                                  const Text(
                                    "Today",
                                    style: TextStyle(
                                      color: Colors.yellowAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Row(
                    children: List.generate(_parts.length, (i) {
                      final selected = i == _partIndex;
                      return Padding(
                        padding: EdgeInsets.only(
                            right: i < _parts.length - 1 ? 8 : 0),
                        child: ChoiceChip(
                          label: Text(
                            _parts[i],
                            style: TextStyle(
                                color:
                                    selected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          selected: selected,
                          selectedColor: Colors.pinkAccent,
                          backgroundColor: const Color(0xFF1E1E1E),
                          onSelected: (_) => setState(() => _partIndex = i),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemCount: filteredMeals.length,
                    itemBuilder: (context, index) {
                      final m = filteredMeals[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.pinkAccent.withOpacity(.25)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(m['image']),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    m['name'],
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                FilledButton.tonal(
                                  onPressed: () =>
                                      bookMeal(m['id'].toString()),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Colors.pinkAccent.withOpacity(.15),
                                    foregroundColor: Colors.pinkAccent,
                                  ),
                                  child: const Text("ADD"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department,
                                    color: Colors.pinkAccent, size: 18),
                                const SizedBox(width: 5),
                                Text('${m['calories']} kcal - 100g',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  String _monthAbbr(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}

// ---------------- Booked Meals Screen ----------------

class BookedMealsScreen extends StatefulWidget {
  const BookedMealsScreen({super.key});

  @override
  State<BookedMealsScreen> createState() => _BookedMealsScreenState();
}

class _BookedMealsScreenState extends State<BookedMealsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _booked = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('meal_reservations')
        .select(
            'id, day, meals(name, part, image, calories, protein_g, fat_g, carbs_g)')
        .eq('user_id', user.id)
        .order('day', ascending: false);

    setState(() => _booked = List<Map<String, dynamic>>.from(response));
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupByDay() {
    final grouped = <DateTime, List<Map<String, dynamic>>>{};
    for (final b in _booked) {
      final mealDate = DateTime.parse(b['day']);
      final key = DateTime(mealDate.year, mealDate.month, mealDate.day);
      grouped.putIfAbsent(key, () => []).add(b);
    }
    final sorted = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sorted) k: grouped[k]!};
  }

  Future<void> _confirmCancel(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            const Text("Confirm Cancel", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to cancel this meal?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("No", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Yes", style: TextStyle(color: Colors.pinkAccent)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) _cancelBooking(id);
  }

  Future<void> _cancelBooking(int id) async {
    await supabase.from('meal_reservations').delete().eq('id', id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Booking canceled ❌")));
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title:
            const Text('Booked Meals', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _booked.isEmpty
          ? const Center(
              child:
                  Text("No booked meals yet", style: TextStyle(color: Colors.white70)))
          : ListView(
              padding: const EdgeInsets.all(14),
              children: grouped.entries.map((entry) {
                final date = entry.key;
                final meals = entry.value;

                final now = DateTime.now();
                String label;
                if (date == DateTime(now.year, now.month, now.day)) {
                  label = "Today";
                } else if (date ==
                    DateTime(now.year, now.month, now.day + 1)) {
                  label = "Tomorrow";
                } else {
                  label = "${date.day} ${_monthAbbr(date.month)} ${date.year}";
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(label,
                          style: const TextStyle(
                              color: Colors.pinkAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                    ...meals.map((b) => _buildMealCard(b)).toList(),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> b) {
    final m = b['meals'];
    final mealDate = DateTime.tryParse(b['day']);
    final now = DateTime.now();
    final isPast =
        mealDate != null && mealDate.isBefore(DateTime(now.year, now.month, now.day));

    final part = m['part'] ?? 'Meal';
    Color partColor;
    switch (part) {
      case 'Breakfast':
        partColor = Colors.orangeAccent;
        break;
      case 'Lunch':
        partColor = Colors.lightGreenAccent.shade400;
        break;
      case 'Dinner':
        partColor = Colors.lightBlueAccent.shade200;
        break;
      default:
        partColor = Colors.white70;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast
              ? Colors.redAccent.withOpacity(.4)
              : Colors.pinkAccent.withOpacity(.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage(m['image'])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['name'],
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: partColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: partColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        part,
                        style: TextStyle(
                            color: partColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${b['day']} | ${m['calories']} kcal",
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!isPast)
                OutlinedButton(
                  onPressed: () => _confirmCancel(b['id']),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.pinkAccent.withOpacity(.8)),
                    foregroundColor: Colors.pinkAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CANCEL"),
                ),
            ],
          ),
          const Divider(height: 20, color: Colors.white12),
          Text(
            "Protein: ${m['protein_g']}g   Fat: ${m['fat_g']}g   Carbs: ${m['carbs_g']}g",
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          if (isPast)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: const [
                  Icon(Icons.access_time_filled,
                      color: Colors.redAccent, size: 16),
                  SizedBox(width: 6),
                  Text("⏰ This meal’s time has passed",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _monthAbbr(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}
