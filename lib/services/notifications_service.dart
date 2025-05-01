import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:academia_unifor/models/notifications.dart';

class NotificationService {
  Future<List<Notifications>> loadNotifications() async {
    final jsonStr = await rootBundle.loadString('assets/mocks/notification.json');
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => Notifications.fromJson(e)).toList();
  }
}
