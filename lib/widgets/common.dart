import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets padding;
  const Section({super.key, required this.title, required this.child, this.padding = const EdgeInsets.symmetric(horizontal:16, vertical:10)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin = const EdgeInsets.symmetric(vertical:8)});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
