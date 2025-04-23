import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/models/workout.dart';
import 'package:dio/dio.dart';

class UsersService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://localhost:7349', // altere para a URL da sua API
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
  ));

  Future<int> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/User/login', data: {
        'email': email,
        'password': password,
      });
      return response.statusCode ?? 0;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return 0;
    }
  }

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

  Future<List<Users>> loadStudents() async {
    try {
      final response = await _dio.get('/api/User/complete/students'); 
      final List<dynamic> data = response.data;
      return data.map((e) => Users.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  Future<Users> getUserById(int id) async {
    try {
      final response = await _dio.get('/api/User/complete/$id');
      return Users.fromJson(response.data);
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      rethrow;
    }
  }

  Future<List<Workout>> getWorkoutsByUserId(int id) async {
    try {
      final response = await _dio.get('/api/Workout/userid/$id');
      final List<dynamic> data = response.data;
      return data.map((e) => Workout.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar treinos: $e');
      return [];
    }
  }

  Future<Workout> postWorkout(Workout workout) async {
    try {
      final response = await _dio.post('/api/Workout', data: workout.toJson());
      return Workout.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      rethrow;
    }
  
  }
  Future<Workout> putWorkout(Workout workout) async {
    try {
      final response = await _dio.put('/api/Workout/${workout.id}', data: workout.toJson());
      return Workout.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      rethrow;
    }
  }
  Future<Workout> deleteWorkout(int id) async {
    try {
      final response = await _dio.delete('/api/Workout/$id');
      return Workout.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar treino: $e');
      rethrow;
    }
  }

}
