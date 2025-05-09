import 'package:flutter/material.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models.dart';

class NotificationAdminScreen extends StatefulWidget {
  const NotificationAdminScreen({super.key});

  @override
  State<NotificationAdminScreen> createState() =>
      _NotificationAdminScreenState();
}

class _NotificationAdminScreenState extends State<NotificationAdminScreen> {
  List<Notifications> allNotifications = [];
  List<Notifications> filteredNotifications = [];
  final NotificationService _notificationService = NotificationService();
  bool _hasUnsavedChanges = false;

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
      filteredNotifications =
          allNotifications
              .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> _updateNotification(Notifications updated) async {
    try {
      if (updated.id == 0) {
        final created = await _notificationService.postNotification(updated);
        setState(() {
          allNotifications.add(created);
          filteredNotifications = List.from(allNotifications);
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificação criada com sucesso!')),
        );
      } else {
        await _notificationService.putNotification(updated);
        setState(() {
          final index = allNotifications.indexWhere((n) => n.id == updated.id);
          if (index != -1) {
            allNotifications[index] = updated;
            filteredNotifications = List.from(allNotifications);
            _hasUnsavedChanges = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificação atualizada com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar notificação: $e')));
    }
  }

  Future<void> _deleteNotification(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
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

    if (confirmed == true) {
      try {
        await _notificationService.deleteNotification(id);
        setState(() {
          allNotifications.removeWhere((n) => n.id == id);
          filteredNotifications = List.from(allNotifications);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificação excluída com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir notificação: $e')),
        );
      }
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
                    builder:
                        (_) => EditNotificationScreen(
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
                  builder:
                      (_) => EditNotificationScreen(
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
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(notification.id),
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
  final bool hasUnsavedChanges;

  const EditNotificationScreen({
    super.key,
    required this.notification,
    required this.isEditing,
    this.hasUnsavedChanges = false,
  });

  @override
  State<EditNotificationScreen> createState() => _EditNotificationScreenState();
}

class _EditNotificationScreenState extends State<EditNotificationScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.notification.title);
    _descController = TextEditingController(
      text: widget.notification.description,
    );
    _hasChanges = widget.hasUnsavedChanges;

    _titleController.addListener(_checkForChanges);
    _descController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanges =
        _titleController.text != widget.notification.title ||
        _descController.text != widget.notification.description;
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  Future<bool> _confirmExit() async {
    if (!_hasChanges) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Alterações não salvas'),
            content: const Text(
              'Você tem alterações não salvas. Deseja sair mesmo assim?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sair'),
              ),
            ],
          ),
    );

    return confirmed ?? false;
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A notificação deve ter um título')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Salvar alterações'),
            content: const Text(
              'Deseja salvar as alterações nesta notificação?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salvar'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    final updated = Notifications(
      id: widget.notification.id,
      title: _titleController.text,
      description: _descController.text,
      createdAt: widget.notification.createdAt,
    );

    if (mounted) {
      Navigator.pop(context, updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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

    if (confirmed == true && mounted) {
      Navigator.pop(context, null); // Retorna null para indicar exclusão
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final canPop = await _confirmExit();
          if (canPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? "Editar Notificação" : "Criar Notificação",
          ),
          actions: [
            IconButton(
              icon:
                  _isSaving
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
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.isEditing) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Apagar Notificação'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
