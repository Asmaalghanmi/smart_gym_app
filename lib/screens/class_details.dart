import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mys_app/main.dart';

class ClassDetailsScreen extends StatefulWidget {
  final int sessionId;
  final String title;
  final String time;
  final String duration;
  final String description;
  final String instructorName;
  final String instructorExp;
  final String imagePath;
  final String instructorImagePath;
  final bool isFull;

  const ClassDetailsScreen({
    super.key,
    required this.sessionId,
    required this.title,
    required this.time,
    required this.duration,
    required this.description,
    required this.instructorName,
    required this.instructorExp,
    required this.imagePath,
    required this.instructorImagePath,
    required this.isFull,
  });

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> _bookClass(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to book a class.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // ✅ تحقق أولاً هل المستخدم حجز نفس الكلاس من قبل
      final existing = await supabase
          .from('bookings')
          .select()
          .eq('user_id', user.id)
          .eq('session_id', widget.sessionId);

      if (existing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already booked this class before.'),
            backgroundColor: Colors.amber,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // ✅ إدخال الحجز الجديد
      await supabase.from('bookings').insert({
        'user_id': user.id,
        'session_id': widget.sessionId,
        'booked_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on PostgrestException catch (e) {
      debugPrint('❌ Postgres error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.imagePath,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                height: 250,
                color: Colors.grey[800],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.time,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(widget.duration,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(widget.description,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.instructorImagePath),
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.instructorName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                          Text(widget.instructorExp,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.isFull || isLoading
                        ? null
                        : () => _bookClass(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isFull
                          ? Colors.grey
                          : const Color(0xFFB388FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isFull
                                ? 'Class Full'
                                : 'Book This Class',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
