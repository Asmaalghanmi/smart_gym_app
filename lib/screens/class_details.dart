import 'package:flutter/material.dart';

class ClassDetailsScreen extends StatelessWidget {
  final String title;
  final String time;
  final String duration;
  final String description;
  final String instructorName;
  final String instructorExp;
  final String imagePath;
  final String instructorImagePath;
  final bool isFull; // إن كانت الحصة ممتلئة

  const ClassDetailsScreen({
    super.key,
    required this.title,
    required this.time,
    required this.duration,
    required this.description,
    required this.instructorName,
    required this.instructorExp,
    required this.imagePath,
    required this.instructorImagePath,
    this.isFull = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull ? Colors.white12 : const Color(0xFFF48FB1),
                foregroundColor: isFull ? Colors.white54 : Colors.black,
                shape: const StadiumBorder(),
              ),
              onPressed: isFull ? null : () {
                // TODO: نفّذ منطق الحجز هنا
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booked successfully')),
                );
              },
              child: Text(isFull ? 'Full' : 'Book'),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imagePath.startsWith('assets/') || imagePath.startsWith('lib/assets/')
                ? Image.asset(imagePath, height: 200, width: double.infinity, fit: BoxFit.cover)
                : Image.network(imagePath, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text('$time • $duration', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: (instructorImagePath.startsWith('assets/') || instructorImagePath.startsWith('lib/assets/'))
                    ? AssetImage(instructorImagePath) as ImageProvider
                    : NetworkImage(instructorImagePath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(instructorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(instructorExp, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 80), // مساحة إضافية فوق الزر
        ],
      ),
    );
  }
}
