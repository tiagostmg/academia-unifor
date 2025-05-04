import 'package:flutter/material.dart';


class ListCategories extends StatelessWidget {
  final Map<String, int> categoryCounts;
  final Color chipColor;
  final Color textColor;
  final void Function(String) onChipTap;

  const ListCategories({
    super.key,
    required this.categoryCounts,
    required this.chipColor,
    required this.textColor,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Pesquise por um aparelho...",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: categoryCounts.entries.map((entry) {
                final name = entry.key;
                final total = entry.value;
                return ActionChip(
                  label: Text('$name ($total)'),
                  backgroundColor: chipColor,
                  labelStyle: TextStyle(color: textColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.transparent),
                  ),
                  onPressed: () => onChipTap(name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}