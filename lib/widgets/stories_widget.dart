import 'package:flutter/material.dart';

class StoriesWidget extends StatelessWidget {
  const StoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stories = [
      {'name': 'Alice', 'color': Colors.red},
      {'name': 'Bob', 'color': Colors.blue},
      {'name': 'Charlie', 'color': Colors.green},
      {'name': 'David', 'color': Colors.orange},
      {'name': 'Eve', 'color': Colors.purple},
    ];

    return SizedBox(
      height: 100, // Altura para os stories
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final story = stories[index];
          return Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: story['color'], width: 3),
                ),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                story['name'],
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
