import 'package:academia_unifor/models/users.dart';
import 'package:dio/dio.dart';

class UsersService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://localhost:7349', // altere para a URL da sua API
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
  ));

  Future<List<Users>> loadUsers() async {
    try {
      final response = await _dio.get('/api/User/complete'); 
      final List<dynamic> data = response.data;
      return data.map((e) => Users.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  //Criei esse medodo para filtrar os usuários que não são admin
  Future<List<Users>> loadStudents() async {
    try {
      final response = await _dio.get('/api/User/complete'); 
      final List<dynamic> data = response.data;
      return data.map((e) => Users.fromJson(e)).where((e) => !e.isAdmin).toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }
}
