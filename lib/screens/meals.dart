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
        scaffoldBackgroundColor: Color(0xFF121212),
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
    // Breakfast
    {
      'icon': Icons.breakfast_dining, // منطقي للفطور
      'color': Color(0xffFF9800),
      'name': 'Boiled Eggs with Wholegrain Toast and Avocado',
      'calories': 350,
      'protein_g': 19,
      'fat_g': 15,
      'carbs_g': 35,
      'part': 'Breakfast',
    },
    {
      'icon': Icons.coffee, // وجبة فطور مع مشروب صحي
      'color': Color(0xffFFCCBC),
      'name': 'Oatmeal with Milk, Banana & Peanut Butter',
      'calories': 320,
      'protein_g': 12,
      'fat_g': 10,
      'carbs_g': 46,
      'part': 'Breakfast',
    },
    {
      'icon': Icons.yard, // رمز للمنتجات الطازجة والخضروات
      'color': Color(0xffDCE775),
      'name': 'Low-fat Labneh with Brown Bread & Veggies',
      'calories': 260,
      'protein_g': 13,
      'fat_g': 7,
      'carbs_g': 32,
      'part': 'Breakfast',
    },

    // Lunch
    {
      'icon': Icons.lunch_dining, // بطبيعة الحال للغداء
      'color': Color(0xff81D4FA),
      'name': 'Grilled Chicken Breast with Brown Rice and Broccoli',
      'calories': 500,
      'protein_g': 38,
      'fat_g': 12,
      'carbs_g': 48,
      'part': 'Lunch',
    },
    {
      'icon': Icons.set_meal, // طبق متكامل
      'color': Color(0xffAED581),
      'name': 'Tuna Salad with Beans and Mixed Veggies',
      'calories': 430,
      'protein_g': 27,
      'fat_g': 11,
      'carbs_g': 50,
      'part': 'Lunch',
    },
    {
      'icon': Icons.restaurant_menu, // عشاء أو غداء متكامل
      'color': Color(0xff4DB6AC),
      'name': 'Grilled Steak (100g) with Roasted Potatoes & Green Salad',
      'calories': 470,
      'protein_g': 32,
      'fat_g': 17,
      'carbs_g': 40,
      'part': 'Lunch',
    },

    // Dinner
    {
      'icon': Icons.dinner_dining,
      'color': Color(0xff7986CB),
      'name': 'Grilled Salmon with Roasted Vegetables',
      'calories': 400,
      'protein_g': 32,
      'fat_g': 22,
      'carbs_g': 16,
      'part': 'Dinner',
    },
    {
      'icon': Icons.fastfood,
      'color': Color(0xffBA68C8),
      'name': 'Chickpea Curry with Spinach and Basmati Rice',
      'calories': 390,
      'protein_g': 14,
      'fat_g': 8,
      'carbs_g': 58,
      'part': 'Dinner',
    },
    {
      'icon': Icons.egg,
      'color': Color(0xffFFD54F),
      'name': 'Two Eggs with Low-fat Cottage Cheese and Salad',
      'calories': 315,
      'protein_g': 24,
      'fat_g': 15,
      'carbs_g': 12,
      'part': 'Dinner',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final days = List<DateTime>.generate(
      7,
      (i) => DateTime(
          _selectedDay.year, _selectedDay.month, _selectedDay.day + i - 3),
    );

    final todayPart = _parts[_partIndex];
    final filteredMeals =
        _mockMeals.where((m) => m['part'] == todayPart).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          "My Meals",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share, color: Colors.white)),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: days.length,
                itemBuilder: (ctx, i) {
                  final d = days[i];
                  final active = d.day == _selectedDay.day &&
                      d.month == _selectedDay.month;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 45,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.pinkAccent
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: active ? Colors.pinkAccent : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _monthAbbr(d.month),
                              style: TextStyle(
                                color: Colors.white.withOpacity(.72),
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              d.day.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: List.generate(_parts.length, (i) {
                final selected = i == _partIndex;
                return Padding(
                  padding:
                      EdgeInsets.only(right: i < _parts.length - 1 ? 8 : 0),
                  child: ChoiceChip(
                    label: Text(_parts[i],
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    selected: selected,
                    selectedColor: Colors.pinkAccent,
                    backgroundColor: const Color(0xFF1E1E1E),
                    onSelected: (_) => setState(() => _partIndex = i),
                    showCheckmark: selected,
                    checkmarkColor: Colors.black,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
                final color =
                    m['color'] is Color ? m['color'] : Colors.pinkAccent;
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: Colors.pinkAccent.withOpacity(.22)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color,
                            child: Icon(m['icon'] ?? Icons.restaurant,
                                color: Colors.black87),
                            radius: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(
                            m['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )),
                          const Icon(Icons.more_horiz, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.pinkAccent, size: 18),
                          const SizedBox(width: 5),
                          Text('${m['calories']} kcal -100g',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white60)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _nutrientIndicator(
                              "Protein", m['protein_g'], Colors.greenAccent),
                          _nutrientIndicator(
                              "Fats", m['fat_g'], Colors.orangeAccent),
                          _nutrientIndicator(
                              "Carbs", m['carbs_g'], Colors.amberAccent),
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
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 3),
            Text(
              "$grams" "g",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: color),
            ),
          ],
        ),
        Text(
          name,
          style: const TextStyle(
              fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  String _monthAbbr(int m) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m - 1];
}