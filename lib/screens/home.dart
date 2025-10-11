import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../widgets/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mys_app/main.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainers = const [
      {'name': 'Leslie',  'img': 'lib/assets/images/trainer1.png'},
      {'name': 'Kathryn', 'img': 'lib/assets/images/trainer2.png'},
      {'name': 'Dianne',  'img': 'lib/assets/images/trainer3.png'},
      {'name': 'Floyd',   'img': 'lib/assets/images/trainer4.png'},
      {'name': 'Erica',   'img': 'lib/assets/images/trainer5.png'},
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            title: const Text('Go Gym'),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Section(
              title: 'Personal goal this week',
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sessions', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 12),
                    LinearPercentIndicator(
                      lineHeight: 10,
                      barRadius: const Radius.circular(12),
                      percent: 0.4,
                      linearGradient: const LinearGradient(
                        colors: [Color(0xFFB388FF), Color(0xFFF48FB1)],
                      ),
                      backgroundColor: Colors.white10,
                      animation: true,
                    ),
                    const SizedBox(height: 6),
                    const Text('4 completed', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Section(
              title: 'Upcoming classes',
              child: GlassCard(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('You have no upcoming classes', style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: const Color(0xFFF48FB1),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('View classes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Section(
              title: 'Personal trainers',
              child: SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trainers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final t = trainers[i];
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(t['img'] as String),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t['name'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Section(
              title: 'Upcoming challenges',
              child: GlassCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'lib/assets/images/upcomingchallange.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '12 Weeks Body transtion',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '2 Feb – 17 Mar',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: const Color(0xFFB388FF),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Join'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
