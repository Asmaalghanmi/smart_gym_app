import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'class_details.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  bool _isFirstTime = true; // ✅ أول مرة فقط يبدأ على Mon
  int _selectedDayIndex = 0;

  List<Map<String, dynamic>> _allSessions = [];
  List<Map<String, dynamic>> _bookedClasses = [];

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData({bool keepDay = true}) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      final sessions = await supabase
          .from('class_sessions')
          .select('*, classes(title, trainer, image_url, duration_min, capacity)')
          .order('session_date', ascending: true);

      final booked = user == null
          ? []
          : await supabase
              .from('bookings')
              .select('*, class_sessions!inner(*, classes(title, trainer, image_url, duration_min)))')
              .eq('user_id', user.id);

      setState(() {
        _allSessions = List<Map<String, dynamic>>.from(sessions);
        _bookedClasses = List<Map<String, dynamic>>.from(booked);
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching data: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _cancelBooking(int bookingId, int sessionId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('bookings').delete().eq('id', bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Booking cancelled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchData(keepDay: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error cancelling booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Classes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          labelColor: Colors.purpleAccent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All classes'),
            Tab(text: 'Booked classes'),
          ],
          onTap: (index) {
            setState(() {
              // ✅ أول مرة فقط يبدأ الفلتر على Mon
              if (index == 0 && _isFirstTime) {
                _selectedDayIndex = 0;
                _isFirstTime = false;
              }
            });
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ الفلتر يظهر فقط في تبويب All classes
                if (_tabController.index == 0)
                  Container(
                    height: 60,
                    margin: const EdgeInsets.only(top: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedDayIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                              _isFirstTime = false;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.purpleAccent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.purpleAccent
                                    : Colors.white30,
                              ),
                            ),
                            child: Text(
                              _days[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // ✅ المحتوى
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSessionList(_allSessions, width),
                      _buildBookedClasses(width),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSessionList(List<Map<String, dynamic>> sessions, double width) {
    final filteredSessions = sessions.where((session) {
      if (session['session_date'] == null) return false;
      final date = DateTime.parse(session['session_date']);
      final weekdayIndex = (date.weekday % 7);
      return weekdayIndex == _selectedDayIndex + 1;
    }).toList();

    if (filteredSessions.isEmpty) {
      return const Center(
        child: Text(
          'No classes on this day',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSessions.length,
      itemBuilder: (context, index) {
        final session = filteredSessions[index];
        final classInfo = session['classes'] ?? {};
        final dateFormatted = DateFormat('EEE, MMM d')
            .format(DateTime.parse(session['session_date']));

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassDetailsScreen(
                  sessionId: session['id'],
                  title: classInfo['title'] ?? 'No title',
                  time: '$dateFormatted • ${session['start_time'] ?? ''}',
                  duration: '${classInfo['duration_min'] ?? 0} mins',
                  description:
                      'Trainer: ${classInfo['trainer'] ?? 'Unknown'}',
                  instructorName: classInfo['trainer'] ?? 'N/A',
                  instructorExp: 'Supabase Data',
                  imagePath: classInfo['image_url'] ?? '',
                  instructorImagePath:
                      'https://i.pravatar.cc/150?img=${index + 5}',
                  isFull: (session['spots_left'] ?? 0) <= 0,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    classInfo['image_url'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classInfo['title'] ?? 'Untitled Class',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trainer: ${classInfo['trainer'] ?? 'Unknown'}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${classInfo['duration_min'] ?? '--'} mins',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spots left: ${session['spots_left'] ?? '--'}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookedClasses(double width) {
    if (_bookedClasses.isEmpty) {
      return const Center(
        child: Text(
          'No booked classes found',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: _bookedClasses.length,
      itemBuilder: (context, index) {
        final booking = _bookedClasses[index];
        final session = booking['class_sessions'] ?? {};
        final classInfo = session['classes'] ?? {};

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  classInfo['image_url'] ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white54, size: 50),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classInfo['title'] ?? 'Untitled Class',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trainer: ${classInfo['trainer'] ?? 'Unknown'}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel Booking?'),
                            content: const Text(
                                'Are you sure you want to cancel this booking?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('No')),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Yes')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _cancelBooking(booking['id'], session['id']);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Cancel Booking',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
