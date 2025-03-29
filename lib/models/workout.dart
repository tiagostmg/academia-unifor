import 'package:academia_unifor/models/exercise.dart';

class Workout {
  String name;
  String description;
  List<Exercise> exercises;

  Workout({
    required this.name,
    required this.description,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
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
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
