import 'package:academia_unifor/models.dart';
import 'package:dio/dio.dart';

class UserService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.0.110:5404',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  Future<int> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/User/login',
        data: {'email': email, 'password': password},
      );
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

  Future<Users> postUser(Users user) async {
    try {
      final response = await _dio.post('/api/User', data: user.toJson());
      return Users.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      rethrow;
    }
  }

  Future<Users> putUser(Users user) async {
    try {
      final response = await _dio.put(
        '/api/User/${user.id}',
        data: user.toJson(),
      );
      return Users.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      rethrow;
    }
  }

  Future<Users> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/api/User/$id');
      return Users.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
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
      final response = await _dio.put(
        '/api/Workout/${workout.id}',
        data: workout.toJson(),
      );
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

  Future<Exercise> postExercise(Exercise exercise) async {
    try {
      final response = await _dio.post(
        '/api/Exercise',
        data: exercise.toJson(),
      );
      return Exercise.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      rethrow;
    }
  }

  Future<Exercise> putExercise(Exercise exercise) async {
    try {
      final response = await _dio.put(
        '/api/Exercise/${exercise.id}',
        data: exercise.toJson(),
      );
      return Exercise.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      rethrow;
    }
  }

  Future<Exercise> deleteExercise(int id) async {
    try {
      final response = await _dio.delete('/api/Exercise/$id');
      return Exercise.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      rethrow;
    }
  }

  Future<Workout> getWorkoutById(int id) async {
    try {
      final response = await _dio.get('/api/Workout/$id');
      return Workout.fromJson(response.data);
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
      rethrow;
    }
  }
}
