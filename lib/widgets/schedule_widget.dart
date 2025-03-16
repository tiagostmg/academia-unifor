import 'dart:async';
import 'package:flutter/material.dart';

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key});

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  late String status;
  late bool isOpen;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateStatus();
    });
  }

  void _updateStatus() {
    final now = DateTime.now();
    final day = now.weekday;
    final time = now.hour * 60 + now.minute;

    final int openingWeek = 5 * 60 + 30; // 5:30 AM
    final int closingWeek = 22 * 60 + 30; // 10:30 PM
    final int openingSat = 8 * 60; // 8:00 AM
    final int closingSat = 12 * 60; // 12:00 PM

    String newStatus;
    if (day >= 1 && day <= 5) {
      if (time < openingWeek) {
        newStatus = 'Fechada - Abre às 5h30';
      } else if (time < closingWeek) {
        final int minutesLeft = closingWeek - time;
        newStatus =
            'Aberta - Fecha em ${minutesLeft ~/ 60}h${minutesLeft % 60}min';
      } else {
        newStatus = 'Fechada - Abre amanhã às 5h30';
      }
    } else if (day == 6) {
      if (time < openingSat) {
        newStatus = 'Fechada - Abre às 8h';
      } else if (time < closingSat) {
        final int minutesLeft = closingSat - time;
        newStatus =
            'Aberta - Fecha em ${minutesLeft ~/ 60}h${minutesLeft % 60}min';
      } else {
        newStatus = 'Fechada - Abre segunda às 5h30';
      }
    } else {
      newStatus = 'Fechada - Abre segunda às 5h30';
    }

    setState(() {
      status = newStatus;
      isOpen = status.startsWith('Aberta');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [OpeningStatusWidget(status: status, isOpen: isOpen)],
      ),
    );
  }
}

class OpeningStatusWidget extends StatelessWidget {
  final String status;
  final bool isOpen;

  const OpeningStatusWidget({
    super.key,
    required this.status,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onPrimary;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horários',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Seg-Sex: 5h30 - 22h30',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Sábado: 8h - 12h', style: TextStyle(color: textColor)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOpen ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isOpen ? Icons.check_circle : Icons.cancel,
                    color: isOpen ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOpen ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
