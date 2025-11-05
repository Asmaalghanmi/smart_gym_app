import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final supa = Supabase.instance.client;

  DateTime _selectedDay = DateTime.now();
  final List<String> _parts = const ['Breakfast', 'Lunch', 'Dinner'];
  int _partIndex = 0;

  bool _loading = true;
  // all meals for selected day (any part)
  List<Map<String, dynamic>> _dayMeals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _loading = true);
    final uid = supa.auth.currentUser?.id;
    if (uid == null) {
      setState(() { _dayMeals = []; _loading = false; });
      return;
    }
    final start = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final end = start.add(const Duration(days: 1));

    final res = await supa
        .from('meals')
        .select()
        .eq('user_id', uid)
        .gte('date', start.toIso8601String())
        .lt('date', end.toIso8601String())
        .order('date', ascending: true);

    final list = (res as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() 
        ?? <Map<String, dynamic>>[];

    setState(() { _dayMeals = list; _loading = false; });
  }

  void _changeDay(int offset) {
    setState(() {
      _selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + offset);
    });
    _loadMeals();
  }

  Future<void> _addQuickMeal(String part) async {
    final uid = supa.auth.currentUser?.id;
    if (uid == null) return;
    await supa.from('meals').insert({
      'user_id': uid,
      'name': 'Custom meal',
      'calories': 300,
      'protein_g': 20,
      'fat_g': 10,
      'carbs_g': 30,
      'part': part.toLowerCase(),
      'date': DateTime.now().toIso8601String(),
    });
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    final partsRow = _buildPartChips();
    final dayRow = _buildDayRow();

    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Prev day',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => _changeDay(-1),
              ),
              Expanded(child: Center(child: Text(_titleDate(_selectedDay), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)))),
              IconButton(
                tooltip: 'Next day',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => _changeDay(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          dayRow,
          const SizedBox(height: 12),
          partsRow,
          const SizedBox(height: 16),
          if (_loading)
            const Padding(padding: EdgeInsets.only(top: 48), child: Center(child: CircularProgressIndicator()))
          else
            _sectionGrid(part: _parts[_partIndex]),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addQuickMeal(_parts[_partIndex]),
            icon: const Icon(Icons.add_rounded),
            label: Text('Add ${_parts[_partIndex].toLowerCase()}'),
          ),
        ],
      ),
    );
  }

  // 3-box grid for selected part
  Widget _sectionGrid({required String part}) {
    final items = _dayMeals
        .where((m) => (m['part'] ?? '').toString().toLowerCase() == part.toLowerCase())
        .toList();

    final cards = <Widget>[];
    for (final m in items.take(3)) {
      cards.add(_mealBox(m));
    }
    while (cards.length < 3) {
      cards.add(_addBox(part));
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 1,            // one box per row on phone; switch to 2 if you want two columns
      shrinkWrap: true,
      mainAxisSpacing: 12,
      childAspectRatio: 3.6,        // make it feel like a horizontal card
      children: cards,
    );
  }

  Widget _mealBox(Map<String, dynamic> m) {
    final name = (m['name'] ?? 'Meal').toString();
    final kcal = m['calories'] ?? 0;
    final protein = m['protein_g'] ?? 0;
    final fats = m['fat_g'] ?? m['fats_g'] ?? 0;
    final carbs = m['carbs_g'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, child: Icon(Icons.restaurant_rounded, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('$kcal kcal', style: TextStyle(color: Colors.white.withOpacity(.7))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _macroPill('Protein', protein, Colors.green),
                    const SizedBox(width: 8),
                    _macroPill('Fats', fats, Colors.orange),
                    const SizedBox(width: 8),
                    _macroPill('Carbs', carbs, Colors.yellow),
                  ],
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.more_horiz_rounded), onPressed: () {/* options */}),
        ],
      ),
    );
  }

  Widget _addBox(String part) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _addQuickMeal(part),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 18, child: Icon(Icons.add_rounded)),
            const SizedBox(width: 12),
            Expanded(child: Text('Add ${part.toLowerCase()} item')),
          ],
        ),
      ),
    );
  }

  Widget _macroPill(String label, num grams, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('${grams}g $label'),
        ],
      ),
    );
  }

  Widget _buildPartChips() {
    return Row(
      children: List.generate(_parts.length, (i) {
        final selected = i == _partIndex;
        return Padding(
          padding: EdgeInsets.only(right: i < _parts.length - 1 ? 12 : 0),
          child: ChoiceChip(
            label: Text(_parts[i]),
            selected: selected,
            onSelected: (_) {
              setState(() => _partIndex = i);
              // no need to refetch since we fetched all parts for the day
            },
          ),
        );
      }),
    );
  }

  Widget _buildDayRow() {
    final base = _selectedDay;
    final days = List<DateTime>.generate(5, (i) => DateTime(base.year, base.month, base.day + i - 2));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) {
        final isActive = d.year == _selectedDay.year && d.month == _selectedDay.month && d.day == _selectedDay.day;
        return ChoiceChip(
          label: Text(_shortDate(d)),
          selected: isActive,
          onSelected: (_) { setState(() => _selectedDay = d); _loadMeals(); },
        );
      }).toList(),
    );
  }

  String _titleDate(DateTime d) => '${_monthName(d.month)} ${d.day}';
  String _shortDate(DateTime d) => '${_monthAbbr(d.month)} ${d.day}';
  String _monthName(int m) => const ['January','February','March','April','May','June','July','August','September','October','November','December'][m-1];
  String _monthAbbr(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}
