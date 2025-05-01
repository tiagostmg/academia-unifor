import 'package:flutter/material.dart';
import 'package:academia_unifor/models/notifications.dart';

class NotificationCard extends StatelessWidget {
  final Notifications notif;

  const NotificationCard(this.notif, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(notif.title),
        subtitle: Text(notif.description),
        trailing: Text(
          formatDateBR(notif.createdAt),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
String formatDateBR(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/"
         "${date.month.toString().padLeft(2, '0')}/"
         "${date.year}";
}