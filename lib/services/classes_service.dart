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

  Future<Classes> postClass(Classes classes) async {
    try {
      final response = await _dio.post(
        '/api/GymEquipment',
        data: classes.toJson(),
      );
      return Classes.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao adicionar equipamento: $e');
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
      throw Exception('Erro ao atualizar equipamento: $e');
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
}
