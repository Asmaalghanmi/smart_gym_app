import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LockersScreen extends StatefulWidget {
  const LockersScreen({super.key});
  @override
  State<LockersScreen> createState() => _LockersScreenState();
}

class _LockersScreenState extends State<LockersScreen> {
  final supa = Supabase.instance.client;

  // Tune these to mirror your layout in the screenshot
  static const int columns = 12;      // lockers per row
  static const int totalLockers = 120; // total numbered lockers to render
  static const double cell = 42;      // cell size

  bool _loading = true;
  // map by locker number
  final Map<int, Map<String, dynamic>> _byNumber = {};

  @override
  void initState() {
    super.initState();
    _loadLockers();
  }

  Future<void> _loadLockers() async {
    setState(() => _loading = true);

    // Fetch what exists; missing numbers will still render as empty cells
    final res = await supa.from('lockers').select().order('number', ascending: true);

    _byNumber.clear();
    final list = (res as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() 
        ?? <Map<String, dynamic>>[];

    for (final l in list) {
      final n = int.tryParse('${l['number']}');
      if (n != null) _byNumber[n] = l;
    }
    setState(() => _loading = false);
  }

  Color _ageColor(DateTime? lastOpened) {
    if (lastOpened == null) return Colors.red.shade800;
    final days = DateTime.now().difference(lastOpened).inDays;
    if (days <= 7) return Colors.green.shade600;       // within 1 week
    if (days <= 28) return Colors.lightGreen.shade700; // 7–28 days
    if (days <= 90) return Colors.orange.shade700;     // 1–3 months
    return Colors.red.shade700;                        // > 3 months
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadLockers,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Locker activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              FilledButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _legend(),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _heatmap(),
        ],
      ),
    );
  }

  Widget _legend() {
    Widget item(Color c, String t) => Row(children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(t),
        ]);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(Colors.green.shade600, 'Within 1 week'),
        item(Colors.lightGreen.shade700, '7–28 days'),
        item(Colors.orange.shade700, '1–3 months'),
        item(Colors.red.shade700, 'More than 3 months'),
      ],
    );
  }

  Widget _heatmap() {
    final rows = (totalLockers / columns).ceil();
    final uid = supa.auth.currentUser?.id;

    return Column(
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(columns, (c) {
              final n = r * columns + c + 1;
              if (n > totalLockers) {
                return const SizedBox(width: 0, height: 0);
              }
              final locker = _byNumber[n];
              final last = DateTime.tryParse('${locker?['last_opened']}');
              final isMine = locker?['user_id'] == uid;
              final bg = locker == null ? Colors.grey.shade800 : _ageColor(last);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: locker == null ? null : () => _openLocker(locker),
                  child: Tooltip(
                    message: locker == null
                        ? 'Locker $n (unassigned)'
                        : 'Locker $n • last opened ${last != null ? _ago(last) : 'never'}',
                    child: Container(
                      width: cell,
                      height: cell,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isMine ? Colors.white : Colors.black12, width: isMine ? 2 : 1),
                      ),
                      child: Text('$n', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt).inDays;
    if (d == 0) return 'today';
    if (d == 1) return '1 day ago';
    return '$d days ago';
  }

  Future<void> _openLocker(Map<String, dynamic> locker) async {
    final id = locker['id'];
    final isOpen = locker['is_open'] == true;
    if (id == null) return;
    await supa
        .from('lockers')
        .update({'is_open': !isOpen, 'last_opened': DateTime.now().toIso8601String()})
        .eq('id', id);
    _loadLockers();
  }

  Future<void> _exportCsv() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export not implemented')));
  }
}
