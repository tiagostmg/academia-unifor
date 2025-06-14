import 'package:academia_unifor/config/enviroment.dart';
import 'package:dio/dio.dart';
import '../models.dart';

class EquipmentService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  Future<List<EquipmentCategory>> loadCategories() async {
    try {
      final response = await _dio.get('/api/GymEquipmentCategory');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => EquipmentCategory.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<EquipmentCategory> getCategoryById(int id) async {
    try {
      final response = await _dio.get('/api/GymEquipmentCategory/$id');
      if (response.statusCode == 200) {
        return EquipmentCategory.fromJson(response.data);
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<int> getExerciseCount(int id) async {
    try {
      final response = await _dio.get('/api/Exercise/count/{$id}');
      if (response.statusCode == 200) {
        return response.data['count'];
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<List<EquipmentItem>> loadEquipment() async {
    try {
      final response = await _dio.get('/api/GymEquipment');

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => EquipmentItem.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<EquipmentItem> getEquipmentById(int id) async {
    try {
      final response = await _dio.get('/api/GymEquipment/$id');
      if (response.statusCode == 200) {
        return EquipmentItem.fromJson(response.data);
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<EquipmentItem> postEquipment(EquipmentItem equipment) async {
    try {
      final response = await _dio.post(
        '/api/GymEquipment',
        data: equipment.toJson(),
      );
      return EquipmentItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao adicionar equipamento: $e');
    }
  }

  Future<EquipmentItem> putEquipment(EquipmentItem equipment) async {
    try {
      final response = await _dio.put(
        '/api/GymEquipment/${equipment.id}',
        data: equipment.toJson(),
      );
      return EquipmentItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao atualizar equipamento: $e');
    }
  }

  Future<void> deleteEquipment(int id) async {
    try {
      final response = await _dio.delete('/api/GymEquipment/$id');
      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }
}
