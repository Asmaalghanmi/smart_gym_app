import 'package:flutter/material.dart';

class LockersScreen extends StatefulWidget {
  const LockersScreen({super.key});
  @override
  State<LockersScreen> createState() => _LockersScreenState();
}

class _LockersScreenState extends State<LockersScreen> {
  // Layout
  static const int totalLockers = 15;
  static const int columns = 3;
  static const double cell = 72;

  // Selection only (no pre-locked lockers)
  int? _selected;

  // One uniform color
  final Color tileColor = const Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    final rows = (totalLockers / columns).ceil();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final rowHeight = cell + 12;
          final gridHeight = rows * rowHeight - 12;
          final available = constraints.maxHeight;
          final topSpace = ((available - gridHeight) / 2).clamp(24.0, 140.0);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SizedBox(height: topSpace - 48),
              Center(
                child: Text(
                  'Choose a locker',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: List.generate(rows, (r) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(columns, (c) {
                          final n = r * columns + c + 1;
                          if (n > totalLockers) return const SizedBox.shrink();

                          final isSelected = _selected == n;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selected = n),
                              child: Container(
                                width: cell,
                                height: cell,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: tileColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.black26,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(color: Colors.white.withOpacity(.2), blurRadius: 8),
                                  ],
                                ),
                                child: Text(
                                  '$n',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _selected == null ? null : _book,
          icon: const Icon(Icons.lock_rounded),
          label: Text(_selected == null ? 'Select a locker' : 'Book locker #$_selected'),
        ),
      ),
    );
  }

  void _book() {
    final n = _selected!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booked locker #$n (demo)')),
    );
    setState(() {
      _selected = null; // clear selection in demo
    });
  }
}
