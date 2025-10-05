import 'package:flutter/material.dart';
import 'package:mys_app/screens/class_details.dart';
import '../widgets/class_card.dart' as widgets; // alias لمنع أي تعارض أسماء

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All classes', 'Booked classes'];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Classes'),
          bottom: TabBar(
            tabs: tabs.map((t) => Tab(text: t)).toList(),
            isScrollable: false,
          ),
        ),
        body: const TabBarView(
          children: [
            _AllClasses(),
            _BookedClasses(),
          ],
        ),
      ),
    );
  }
}

class _AllClasses extends StatelessWidget {
  const _AllClasses({super.key});

  @override
  Widget build(BuildContext context) {
    final days = const ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed'];

    return Column(
      children: [
        SizedBox(
          height: 54,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(days[i], style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              widgets.ClassCard(
                title: 'Hiit',
                time: '09:30 am',
                duration: '30 mins',
                status: 'Book',
                spotsLeft: 3,
                image: 'lib/assets/images/Hiit_class_pic.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClassDetailsScreen(
                        title: 'Hiit',
                        time: '09:30 am',
                        duration: '30 mins',
                        description:
                            'A high-energy workout alternating between short bursts of intense exercise and brief recovery periods. Benefits: Fat loss, endurance boost, time-efficient results.',
                        instructorName: 'Erica',
                        instructorExp: '8 years of experience',
                        imagePath: 'lib/assets/images/Hiit_class_pic.png',
                        instructorImagePath: 'lib/assets/images/trainer5.png',
                        // isFull: false (افتراضي)
                      ),
                    ),
                  );
                },
              ),
              widgets.ClassCard(
                title: 'Circuits',
                time: '11:30 am',
                duration: '40 mins',
                status: 'Full',
                spotsLeft: 5,
                image: 'lib/assets/images/Circuits_class_pic.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClassDetailsScreen(
                        title: 'Circuits',
                        time: '11:30 am',
                        duration: '40 mins',
                        description:
                            'A full-body functional training class that moves you through various stations for strength, cardio, and core. Benefits: Total body conditioning, variety, improved performance.',
                        instructorName: 'Kathryn',
                        instructorExp: '5 years of experience',
                        imagePath: 'lib/assets/images/Circuits_class_pic.png',
                        instructorImagePath: 'lib/assets/images/trainer2.png',
                        isFull: true, // ممتلئة => الزر سيظهر كـ Full ومُعطّل
                      ),
                    ),
                  );
                },
              ),
              widgets.ClassCard(
                title: 'Yoga',
                time: '02:30 pm',
                duration: '30 mins',
                status: 'Book',
                spotsLeft: 3,
                image: 'lib/assets/images/Yoga_class_pic.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClassDetailsScreen(
                        title: 'Yoga',
                        time: '02:30 pm',
                        duration: '30 mins',
                        description:
                            'A low-impact class to improve flexibility, balance, and mental clarity with guided stretches and breathing. Benefits: Stress relief, increased flexibility, improved posture.',
                        instructorName: 'Dianne',
                        instructorExp: '3 years of experience',
                        imagePath: 'lib/assets/images/Yoga_class_pic.png',
                        instructorImagePath: 'lib/assets/images/trainer3.png',
                      ),
                    ),
                  );
                },
              ),
              widgets.ClassCard(
                title: 'Tone',
                time: '06:00 pm',
                duration: '45 mins',
                status: 'Book',
                spotsLeft: 2,
                image: 'lib/assets/images/Tone_class_pic.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClassDetailsScreen(
                        title: 'Tone',
                        time: '06:00 pm',
                        duration: '45 mins',
                        description:
                            'A sculpting class focusing on defining muscles using bodyweight, bands, or light weights with high reps. Benefits: Muscle tone, improved posture, lean physique.',
                        instructorName: 'Leslie',
                        instructorExp: '5 years of experience',
                        imagePath: 'lib/assets/images/Tone_class_pic.png',
                        instructorImagePath: 'lib/assets/images/trainer1.png',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookedClasses extends StatelessWidget {
  const _BookedClasses({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No booked classes yet', style: TextStyle(color: Colors.white70)),
    );
  }
}

