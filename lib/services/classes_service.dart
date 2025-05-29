import 'package:academia_unifor/config/enviroment.dart';
import 'package:dio/dio.dart';
import '../models.dart';

class ClassesService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  Future<List<Classes>> loadClasses() async {
    try {
      final response = await _dio.get('/api/class');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Classes.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<List<Classes>> loadClassesIncomplete() async {
    try {
      final response = await _dio.get('/api/class/incomplete');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Classes.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<Classes> postClass(Classes classes) async {
    try {
      final response = await _dio.post('/api/class', data: classes.toJson());
      return Classes.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao adicionar aula: $e');
    }
  }

  Future<Classes> putClass(Classes classes) async {
    try {
      final response = await _dio.put(
        ('/api/class/${classes.id}'),
        data: classes.toJson(),
      );
      return Classes.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao atualizar aula: $e');
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      final response = await _dio.delete('/api/class/$id');
      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<Classes> subscribeUser(int classId, int userId) async {
    try {
      final response = await _dio.post(
        '/api/class/subscribe',
        data: {'userId': userId, 'classId': classId},
      );
      return Classes.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao inscrever usuário na aula: $e');
    }
  }

  Future<Classes> unsubscribeUser(int classId, int userId) async {
    try {
      final response = await _dio.post(
        '/api/Class/unsubscribe',
        data: {'userId': userId, 'classId': classId},
      );
      return Classes.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao cancelar inscrição do usuário na aula: $e');
    }
  }
}
