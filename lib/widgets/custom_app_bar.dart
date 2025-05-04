import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:academia_unifor/assets/unifor_logo.dart';
import 'package:academia_unifor/services.dart';
import 'package:academia_unifor/models.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final bool showNotificationIcon;

  const CustomAppBar({super.key, this.showNotificationIcon = true})
    : preferredSize = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      elevation: 1,
      titleSpacing: 0,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            width: 120,
            child: SvgPicture.string(
              uniforLogoSVG,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "Academia",
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: showNotificationIcon
          ? [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  _showNotificationsModal(context);
                },
              ),
            ]
          : null,
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              contentPadding: const EdgeInsets.all(0),
              title: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Notificações',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              content: FutureBuilder<List<Notifications>>(
                future: NotificationService().loadNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'Erro ao carregar notificações',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }

                  final notifications = snapshot.data ?? [];

                  if (notifications.isEmpty) {
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Não há notificações',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          title: Text(notification.title),
                          subtitle: Text(notification.description),
                          trailing: Text(
                            _formatDate(notification.createdAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            // Ação ao clicar em uma notificação
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
}