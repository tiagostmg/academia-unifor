import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:academia_unifor/models/notifications.dart';
import 'package:academia_unifor/widgets.dart';

class NotificationAdminScreen extends StatelessWidget {
  const NotificationAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 4,
          child: const NotificationAdminBody(),
        ),
      ),
    );
  }
}

class NotificationAdminBody extends StatefulWidget {
  const NotificationAdminBody({super.key});

  @override
  State<NotificationAdminBody> createState() => _NotificationAdminBodyState();
}

class _NotificationAdminBodyState extends State<NotificationAdminBody> {
  List<Notifications> allNotifications = [];
  List<Notifications> filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final jsonStr = await rootBundle.loadString(
      'assets/mocks/notification.json',
    );
    final List<dynamic> data = json.decode(jsonStr);
    final loaded = data.map((e) => Notifications.fromJson(e)).toList();

    setState(() {
      allNotifications = loaded;
      filteredNotifications = loaded;
    });
  }

  void _filter(String query) {
    setState(() {
      filteredNotifications = allNotifications
          .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onSearchChanged: _filter,
        showChatIcon: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredNotifications.isEmpty
                ? const Center(child: Text('Nenhuma notificação encontrada.'))
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = filteredNotifications[index];
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
                          _formatDate(notif.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}