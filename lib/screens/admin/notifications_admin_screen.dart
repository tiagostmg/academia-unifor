import 'package:academia_unifor/services/notifications_service.dart';
import 'package:flutter/material.dart';
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

  final NotificationService _notificationService = NotificationService();

  Future<void> _loadNotifications() async {
    final loaded = await _notificationService.loadNotifications();
    loaded.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ); // ordenação por data decrescente

    setState(() {
      allNotifications = filteredNotifications = loaded;
    });
  }

  void _filter(String query) {
    setState(() {
      filteredNotifications =
          allNotifications
              .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(onSearchChanged: _filter, showChatIcon: false),
      body: Column(
        children: [
          Expanded(
            child:
                filteredNotifications.isEmpty
                    ? const Center(
                      child: Text('Nenhuma notificação encontrada.'),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        return NotificationCard(filteredNotifications[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
