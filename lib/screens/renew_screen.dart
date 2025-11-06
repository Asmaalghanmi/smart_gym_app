import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedMonths = 1;

  final List<Map<String, dynamic>> plans = [
    {
      "title": "Basic Plan",
      "pricePerMonth": 50,
      "features": [
        "2 group classes per week",
        "Locker access",
      ],
    },
    {
      "title": "Pro Plan",
      "pricePerMonth": 100,
      "features": [
        "4 group classes per week",
        "Personal trainer consultation",
        "Locker access",
      ],
    },
    {
      "title": "Premium Plan",
      "pricePerMonth": 150,
      "features": [
        "Unlimited group classes",
        "Personal trainer consultation",
        "Locker access",
        "Nutrition plan",
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Your Subscription"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          final totalPrice = plan['pricePerMonth'] * selectedMonths;

          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color(0xFF1B1B25),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan["title"],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      "$totalPrice SAR for $selectedMonths month${selectedMonths > 1 ? 's' : ''}",
                      style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const Divider(color: Colors.white24, height: 20),
                  ...plan["features"].map<Widget>((feature) => Row(
                        children: [
                          const Icon(Icons.check,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                              child: Text(feature,
                                  style:
                                      const TextStyle(color: Colors.white70)))
                        ],
                      )),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<int>(
                        dropdownColor: const Color(0xFF1B1B25),
                        value: selectedMonths,
                        items: List.generate(12, (i) => i + 1)
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text("$e month${e > 1 ? 's' : ''}",
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedMonths = val ?? 1;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Selected ${plan["title"]} for $selectedMonths month${selectedMonths > 1 ? 's' : ''}.'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent),
                        child: const Text("Choose Plan"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
