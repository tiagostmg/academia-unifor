import 'package:academia_unifor/models.dart';

class NotificationsValidator {
  static bool validateDescription(String description) {
    if (description.length > 200) {
      return false;
    }
    return true;
  }

  static bool validateNotificationTitle(String title) {
    if (title.isEmpty) {
      return false;
    }
    if (title.length < 2) return false;
    if (title.length > 50) return false;
    return true;
  }

  String? validateNotification(Notifications notification) {
    if (!validateNotificationTitle(notification.title)) {
      return notification.title.isEmpty
          ? 'O título da notificação é obrigatório'
          : 'O título deve ter entre 2 e 50 caracteres';
    }
    if (!validateDescription(notification.description)) {
      return 'A descrição deve ter no máximo 200 caracteres';
    }
    return null;
  }
}
