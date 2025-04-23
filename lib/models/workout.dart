import 'package:academia_unifor/models/exercise.dart';

class Workout {
  int id;
  int userId;
  String name;
  String description;
  List<Exercise> exercises;

  Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? 1,
      userId: json['userId'] ?? 1, 
      name: json['name'],
      description: json['description'],
      exercises:
          (json['exercises'] as List<dynamic>)
              .map((e) => Exercise.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
