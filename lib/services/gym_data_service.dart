import 'package:dio/dio.dart';
import '../models/equipment.dart';

final Dio _dio = Dio(BaseOptions(
  baseUrl: 'https://localhost:7349', // altere para a URL da sua API
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
));

Future<List<EquipmentCategory>> loadGymEquipment() async {
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

