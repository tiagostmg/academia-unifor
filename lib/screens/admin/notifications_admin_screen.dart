import 'package:academia_unifor/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:academia_unifor/models/notifications.dart';
import 'package:academia_unifor/widgets.dart';

class NotificationAdminScreen extends StatefulWidget {
  const NotificationAdminScreen({super.key});

  @override
  State<NotificationAdminScreen> createState() => _NotificationAdminScreenState();
}

class _NotificationAdminScreenState extends State<NotificationAdminScreen> {
  List<Notifications> allNotifications = [];
  List<Notifications> filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifications = await NotificationService().loadNotifications();
    setState(() {
      allNotifications = notifications;
      filteredNotifications = notifications;
    });
  }

  void _filterNotifications(String query) {
    setState(() {
      filteredNotifications = allNotifications
          .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateNotification(Notifications updated) {
    setState(() {
      final index = allNotifications.indexWhere((n) => n.id == updated.id);
      if (index != -1) {
        allNotifications[index] = updated;
        filteredNotifications = List.from(allNotifications);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 3,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(
              onSearchChanged: _filterNotifications,
              showChatIcon: false,
            ),
            body: NotificationsScreenBody(
              notifications: filteredNotifications,
              onUpdateNotification: _updateNotification,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditNotificationScreen(
                      notification: Notifications(
                        id: 0,
                        title: '',
                        description: '',
                        createdAt: DateTime.now(),
                      ),
                      isEditing: false,
                    ),
                  ),
                );
                if (created != null) {
                  setState(() {
                    allNotifications.add(created);
                    filteredNotifications = List.from(allNotifications);
                  });
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationsScreenBody extends StatelessWidget {
  final List<Notifications> notifications;
  final Function(Notifications) onUpdateNotification;

  const NotificationsScreenBody({
    super.key,
    required this.notifications,
    required this.onUpdateNotification,
  });

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}"
        " - ${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notification.title),
            subtitle: Text(_formatDate(notification.createdAt)),
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditNotificationScreen(notification: notification, isEditing: true,),
                ),
              );
              if (updated != null && updated is Notifications) {
                onUpdateNotification(updated);
              }
            },
          );
        },
      ),
    );
  }
}

class EditNotificationScreen extends StatefulWidget {
  final Notifications notification;
  final bool isEditing;

  const EditNotificationScreen({super.key, required this.notification, required this.isEditing});

  @override
  State<EditNotificationScreen> createState() => _EditNotificationScreenState();
}

class _EditNotificationScreenState extends State<EditNotificationScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.notification.title);
    descController = TextEditingController(text: widget.notification.description);
    isEditing = widget.isEditing;
  }

  void _saveChanges() {
    final updated = Notifications(
      id: widget.notification.id,
      title: titleController.text,
      description: descController.text,
      createdAt: widget.notification.createdAt,
    );
    if(updated.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A notificação deve ter um título')),
      );
      return;
    }
    if (isEditing) {
      NotificationService().putNotification(updated);
    } 
    else {
      NotificationService().postNotification(updated);
    }
    Navigator.pop(context, updated);
  }

  void _deleteNotification() {
    NotificationService().deleteNotification(widget.notification.id);
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Notificação" : "Criar Notificação"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _deleteNotification,
              icon: const Icon(Icons.delete),
              label: const Text('Apagar Notificação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
