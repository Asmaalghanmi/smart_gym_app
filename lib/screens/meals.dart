import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

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
  DateTime _selectedDay = DateTime.now();
  final List<String> _parts = ['Breakfast', 'Lunch', 'Dinner'];
  int _partIndex = 0;

  final List<Map<String, dynamic>> _mockMeals = [
    {
      'image': 'https://images.pexels.com/photos/566566/pexels-photo-566566.jpeg',
      'name': 'Boiled Eggs with Wholegrain Toast and Avocado',
      'calories': 350, 'protein_g': 19, 'fat_g': 15, 'carbs_g': 35, 'part': 'Breakfast',
    },
    {
      'image': 'https://images.pexels.com/photos/8005369/pexels-photo-8005369.jpeg',
      'name': 'Oatmeal with Milk, Banana & Peanut Butter',
      'calories': 320, 'protein_g': 12, 'fat_g': 10, 'carbs_g': 46, 'part': 'Breakfast',
    },
    {
      'image': 'https://images.pexels.com/photos/5292918/pexels-photo-5292918.jpeg',
      'name': 'Low-fat Labneh with Brown Bread & Veggies',
      'calories': 260, 'protein_g': 13, 'fat_g': 7, 'carbs_g': 32, 'part': 'Breakfast',
    },
    {
      'image': 'https://images.pexels.com/photos/30635713/pexels-photo-30635713.jpeg',
      'name': 'Grilled Chicken Breast with Brown Rice and Broccoli',
      'calories': 500, 'protein_g': 38, 'fat_g': 12, 'carbs_g': 48, 'part': 'Lunch',
    },
    {
      'image': 'https://images.pexels.com/photos/19859349/pexels-photo-19859349.jpeg',
      'name': 'Tuna Salad with Beans and Mixed Veggies',
      'calories': 430, 'protein_g': 27, 'fat_g': 11, 'carbs_g': 50, 'part': 'Lunch',
    },
    {
      'image': 'https://images.pexels.com/photos/18284912/pexels-photo-18284912.jpeg',
      'name': 'Grilled Steak (100g) with Roasted Potatoes & Green Salad',
      'calories': 470, 'protein_g': 32, 'fat_g': 17, 'carbs_g': 40, 'part': 'Lunch',
    },
    {
      'image': 'https://images.pexels.com/photos/5639499/pexels-photo-5639499.jpeg',
      'name': 'Grilled Salmon with Roasted Vegetables',
      'calories': 400, 'protein_g': 32, 'fat_g': 22, 'carbs_g': 16, 'part': 'Dinner',
    },
    {
      'image': 'https://images.pexels.com/photos/10464100/pexels-photo-10464100.jpeg',
      'name': 'Chickpea Curry with Spinach and Basmati Rice',
      'calories': 390, 'protein_g': 14, 'fat_g': 8, 'carbs_g': 58, 'part': 'Dinner',
    },
    {
      'image': 'https://images.pexels.com/photos/3850992/pexels-photo-3850992.jpeg',
      'name': 'Two Eggs with Low-fat Cottage Cheese and Salad',
      'calories': 315, 'protein_g': 24, 'fat_g': 15, 'carbs_g': 12, 'part': 'Dinner',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final days = List<DateTime>.generate(
      7, (i) => DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + i - 3),
    );

    final todayPart = _parts[_partIndex];
    final filteredMeals = _mockMeals.where((m) => m['part'] == todayPart).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text("My Meals", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookedMealsScreen()),
              );
            },
            child: const Text(
              'VIEW',
              style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.w800, letterSpacing: .8),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRect(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: days.length,
                itemBuilder: (ctx, i) {
                  final d = days[i];
                  final active = d.day == _selectedDay.day && d.month == _selectedDay.month;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 45,
                      decoration: BoxDecoration(
                        color: active ? Colors.pinkAccent : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: active ? Colors.pinkAccent : Colors.white24, width: 1.2),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _monthAbbr(d.month),
                              style: TextStyle(color: Colors.white.withOpacity(.72), fontWeight: FontWeight.w600, fontSize: 9),
                            ),
                            Text(
                              d.day.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: List.generate(_parts.length, (i) {
                final selected = i == _partIndex;
                return Padding(
                  padding: EdgeInsets.only(right: i < _parts.length - 1 ? 8 : 0),
                  child: ChoiceChip(
                    label: Text(
                      _parts[i],
                      style: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                    ),
                    selected: selected,
                    selectedColor: Colors.pinkAccent,
                    backgroundColor: const Color(0xFF1E1E1E),
                    onSelected: (_) => setState(() => _partIndex = i),
                    showCheckmark: selected,
                    checkmarkColor: Colors.black,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                final m = filteredMeals[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.pinkAccent.withOpacity(.22)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: (m['image'] != null && m['image'] != '') ? NetworkImage(m['image']) : null,
                            backgroundColor: Colors.transparent,
                            child: (m['image'] == null || m['image'] == '')
                                ? const Icon(Icons.no_photography, color: Colors.black38)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              m['name'] ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              // Demo add action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added: ${m['name']}')),
                              );
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              backgroundColor: Colors.pinkAccent.withOpacity(.18),
                              foregroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2),
                            ),
                            child: const Text('ADD'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.pinkAccent, size: 18),
                          const SizedBox(width: 5),
                          Text('${m['calories']} kcal -100g', style: const TextStyle(fontSize: 13, color: Colors.white60)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _nutrientIndicator("Protein", m['protein_g'], Colors.greenAccent),
                          _nutrientIndicator("Fats", m['fat_g'], Colors.orangeAccent),
                          _nutrientIndicator("Carbs", m['carbs_g'], Colors.amberAccent),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _nutrientIndicator(String name, int grams, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(height: 8, width: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 3),
            Text("$grams" "g", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          ],
        ),
        Text(name, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _monthAbbr(int m) => const [
        'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];
}

class BookedMealsScreen extends StatefulWidget {
  const BookedMealsScreen({super.key});

  @override
  State<BookedMealsScreen> createState() => _BookedMealsScreenState();
}

class _BookedMealsScreenState extends State<BookedMealsScreen> {
  final List<Map<String, dynamic>> _bookedMeals = [
    {
      'image': 'https://images.pexels.com/photos/5639499/pexels-photo-5639499.jpeg',
      'name': 'Grilled Salmon with Roasted Vegetables',
      'calories': 400, 'protein_g': 32, 'fat_g': 22, 'carbs_g': 16,
      'date': DateTime.now(), // today
    },
    {
      'image': 'https://images.pexels.com/photos/8005369/pexels-photo-8005369.jpeg',
      'name': 'Oatmeal with Milk, Banana & Peanut Butter',
      'calories': 320, 'protein_g': 12, 'fat_g': 10, 'carbs_g': 46,
      'date': DateTime.now().add(const Duration(days: 1)), // tomorrow
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Meals'),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: _bookedMeals.isEmpty
          ? Center(
              child: Text(
                'No booked meals yet',
                style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 18, fontWeight: FontWeight.w600),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemCount: _bookedMeals.length,
              itemBuilder: (context, index) {
                final m = _bookedMeals[index];
                final date = m['date'] as DateTime;
                final dateStr = '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.pinkAccent.withOpacity(.22)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: (m['image'] != null && m['image'] != '') ? NetworkImage(m['image']) : null,
                            backgroundColor: Colors.transparent,
                            child: (m['image'] == null || m['image'] == '')
                                ? const Icon(Icons.no_photography, color: Colors.black38)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              m['name'] ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          // CANCEL button
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _bookedMeals.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Booking canceled')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.pinkAccent.withOpacity(.8)),
                              foregroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            child: const Text('CANCEL'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.event, color: Colors.pinkAccent, size: 18),
                          const SizedBox(width: 6),
                          Text('Booked on $dateStr', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.pinkAccent, size: 18),
                          const SizedBox(width: 5),
                          Text('${m['calories']} kcal -100g', style: const TextStyle(fontSize: 13, color: Colors.white60)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _monthAbbr(int m) => const [
        'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];
}
