import 'package:dio/dio.dart';
import 'package:academia_unifor/models/notifications.dart';

class NotificationService {

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:5404', // altere para a URL da sua API
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
  ));
  
  Future<List<Notifications>> loadNotifications() async {
    try {
      final response = await _dio.get('/api/Notification'); 
      final List<dynamic> data = response.data;
      return data.map((e) => Notifications.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  Future<Notifications> getNotificationById(int id) async {
    try {
      final response = await _dio.get('/api/Notification/$id');
      return Notifications.fromJson(response.data);
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      rethrow;
    }
  }

  Future<Notifications> postNotification(Notifications notification) async {
    try {
      final response = await _dio.post('/api/Notification', data: notification.toJson());
      return Notifications.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      rethrow;
    }
  
  }

  Future<Notifications> putNotification(Notifications notification) async {
    try {
      final response = await _dio.put('/api/Notification/${notification.id}', data: notification.toJson());
      return Notifications.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      rethrow;
    }
  }

  Future<Notifications> deleteNotification(int id) async {
    try {
      final response = await _dio.delete('/api/Notification/$id');
      return Notifications.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      rethrow;
    }
  }
}
