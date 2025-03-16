import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Equipamentos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: const [
                  InfoRow(
                    number: '40',
                    label: 'Máquinas para treinamento de força',
                  ),
                  SizedBox(height: 8),
                  InfoRow(
                    number: '24',
                    label: 'Aparelhos ergométricos (cárdio)',
                  ),
                  SizedBox(height: 8),
                  InfoRow(number: '12', label: 'Esteiras'),
                  SizedBox(height: 8),
                  InfoRow(
                    number: '11',
                    label: 'Bikes para atividades de spinning',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String number;
  final String label;

  const InfoRow({required this.number, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onPrimary;
    final isDarkMode = theme.brightness == Brightness.dark;
    final circleColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: circleColor,
          child: Text(
            number,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14, color: textColor)),
        ),
      ],
    );
  }
}
