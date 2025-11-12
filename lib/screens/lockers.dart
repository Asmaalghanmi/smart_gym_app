import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LockersScreen extends StatefulWidget {
  const LockersScreen({super.key});
  @override
  State<LockersScreen> createState() => _LockersScreenState();
}

class _LockersScreenState extends State<LockersScreen> {
  static const int totalLockers = 15;
  static const int columns = 3;
  static const double cell = 72;

  int? _selected;
  final Color tileColor = Colors.pinkAccent;

  final supabase = Supabase.instance.client;
  Set<int> bookedLockers = {};
  int? userLocker;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLockers();
  }

  Future<void> _fetchLockers() async {
    setState(() => loading = true);

    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('locker_reservations')
        .select('locker_number, user_id')
        .filter('released_at', 'is', null);

    final data = (response as List);

    final allBooked = <int>{};
    int? myLocker;

    for (final row in data) {
      final num = row['locker_number'] as int;
      allBooked.add(num);
      if (row['user_id'] == user?.id) myLocker = num;
    }

    setState(() {
      bookedLockers = allBooked;
      userLocker = myLocker;
      loading = false;
    });
  }

  Future<void> _bookLocker() async {
    if (_selected == null) return;

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book a locker')),
      );
      return;
    }

    final lockerNumber = _selected!;

    if (bookedLockers.contains(lockerNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Locker #$lockerNumber is already booked')),
      );
      return;
    }

    // لو المستخدم حاجز قبل، نحذف القديم أول
    if (userLocker != null) {
      await supabase
          .from('locker_reservations')
          .update({'released_at': DateTime.now().toIso8601String()})
          .eq('user_id', user.id)
          .filter('released_at', 'is', null);
    }

    await supabase.from('locker_reservations').insert({
      'locker_number': lockerNumber,
      'user_id': user.id,
      'booked_at': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Locker #$lockerNumber booked successfully')),
    );

    _fetchLockers();
    setState(() => _selected = null);
  }

  Future<void> _cancelLocker() async {
    final user = supabase.auth.currentUser;
    if (user == null || userLocker == null) return;

    await supabase
        .from('locker_reservations')
        .update({'released_at': DateTime.now().toIso8601String()})
        .eq('user_id', user.id)
        .filter('released_at', 'is', null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Locker reservation canceled')),
    );

    _fetchLockers();
  }

  @override
  Widget build(BuildContext context) {
    final rows = (totalLockers / columns).ceil();

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final rowHeight = cell + 12;
                final gridHeight = rows * rowHeight - 12;
                final available = constraints.maxHeight;
                final topSpace =
                    ((available - gridHeight) / 2).clamp(24.0, 140.0);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    SizedBox(height: topSpace - 48),
                    const Center(
                      child: Text(
                        'Choose a locker',
                        style: TextStyle(
                            fontSize: 34, fontWeight: FontWeight.w700),
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
                                if (n > totalLockers) {
                                  return const SizedBox.shrink();
                                }

                                final isSelected = _selected == n;
                                final isBooked = bookedLockers.contains(n);
                                final isMine = userLocker == n;

                                Color color;
                                if (isMine) {
                                  color = Colors.grey; // لوكر المستخدم
                                } else if (isBooked) {
                                  color = Colors.redAccent.shade100;
                                } else {
                                  color = tileColor;
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: isBooked && !isMine
                                        ? null
                                        : () => setState(() => _selected = n),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: cell,
                                          height: cell,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black26,
                                              width: isSelected ? 3 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            '$n',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18),
                                          ),
                                        ),
                                        if (isBooked && !isMine)
                                          const Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Icon(Icons.close,
                                                size: 22, color: Colors.black),
                                          ),
                                      ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userLocker != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'You currently have locker #$userLocker',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            Row(
              children: [
                if (userLocker == null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _selected == null ? null : _bookLocker,
                      icon: const Icon(Icons.lock_rounded),
                      label: Text(_selected == null
                          ? 'Select a locker'
                          : 'Book locker #$_selected'),
                    ),
                  )
                else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelLocker,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Reservation'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _selected == null ? null : _bookLocker,
                      icon: const Icon(Icons.change_circle_outlined),
                      label: const Text('Change Locker'),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
