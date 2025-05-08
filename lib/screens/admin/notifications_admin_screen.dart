import 'package:flutter/material.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models.dart';

class NotificationAdminScreen extends StatefulWidget {
  const NotificationAdminScreen({super.key});

  @override
  State<NotificationAdminScreen> createState() => _NotificationAdminScreenState();
}

class _NotificationAdminScreenState extends State<NotificationAdminScreen> {
  List<Notifications> allNotifications = [];
  List<Notifications> filteredNotifications = [];
  final NotificationService _notificationService = NotificationService();

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _notificationService.loadNotifications();
      setState(() {
        allNotifications = notifications;
        filteredNotifications = notifications;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar notificações: $e')),
      );
    }
  }

  void _filterNotifications(String query) {
    setState(() {
      filteredNotifications = allNotifications
          .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _updateNotification(Notifications updated) async {
    try {
      if (updated.id == 0) {
        // Nova notificação
        final created = await _notificationService.postNotification(updated);
        setState(() {
          allNotifications.add(created);
          filteredNotifications = List.from(allNotifications);
        });
      } else {
        // Notificação existente
        await _notificationService.putNotification(updated);
        setState(() {
          final index = allNotifications.indexWhere((n) => n.id == updated.id);
          if (index != -1) {
            allNotifications[index] = updated;
            filteredNotifications = List.from(allNotifications);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar notificação: $e')),
      );
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await _notificationService.deleteNotification(id);
      setState(() {
        allNotifications.removeWhere((n) => n.id == id);
        filteredNotifications = List.from(allNotifications);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar notificação: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 2,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(
              onSearchChanged: _filterNotifications,
              showChatIcon: false,
            ),
            body: NotificationsScreenBody(
              notifications: filteredNotifications,
              onUpdate: _updateNotification,
              onDelete: _deleteNotification,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
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
                if (result != null && result is Notifications) {
                  await _updateNotification(result);
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
  final Future<void> Function(Notifications) onUpdate;
  final Future<void> Function(int) onDelete;

  const NotificationsScreenBody({
    super.key,
    required this.notifications,
    required this.onUpdate,
    required this.onDelete,
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
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditNotificationScreen(
                    notification: notification,
                    isEditing: true,
                  ),
                ),
              );
              if (result != null && result is Notifications) {
                await onUpdate(result);
              }
            },
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar exclusão'),
                    content: const Text('Deseja realmente excluir esta notificação?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await onDelete(notification.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class EditNotificationScreen extends StatefulWidget {
  final Notifications notification;
  final bool isEditing;

  const EditNotificationScreen({
    super.key,
    required this.notification,
    required this.isEditing,
  });

  @override
  State<EditNotificationScreen> createState() => _EditNotificationScreenState();
}

class _EditNotificationScreenState extends State<EditNotificationScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.notification.title);
    _descController = TextEditingController(text: widget.notification.description);
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A notificação deve ter um título')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = Notifications(
      id: widget.notification.id,
      title: _titleController.text,
      description: _descController.text,
      createdAt: widget.notification.createdAt,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Editar Notificação" : "Criar Notificação"),
        actions: [
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
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
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, null); // Retorna null para indicar exclusão
                },
                icon: const Icon(Icons.delete),
                label: const Text('Apagar Notificação'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}