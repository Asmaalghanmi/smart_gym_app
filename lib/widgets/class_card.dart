import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String title;
  final String time;
  final String duration;
  final String status;   // لم يعد لها تأثير على الزر هنا
  final int spotsLeft;   // كذلك
  final String image;
  final VoidCallback? onTap;

  const ClassCard({
    super.key,
    required this.title,
    required this.time,
    required this.duration,
    required this.status,
    required this.spotsLeft,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.startsWith('assets/') || image.startsWith('lib/assets/')
                ? Image.asset(image, width: 56, height: 56, fit: BoxFit.cover)
                : Image.network(image, width: 56, height: 56, fit: BoxFit.cover),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '$time — $duration',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70),
          ),
          
trailing: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      status == 'Full' ? 'Full' : 'available',
      style: TextStyle(
        color: status == 'Full' ? Colors.red : Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      '$spotsLeft spaces left',
      style: const TextStyle(color: Colors.white54, fontSize: 12),
    ),
  ],
),
        ),
      ),
    );
  }
}

