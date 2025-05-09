import 'package:academia_unifor/models/workout.dart';

class WorkoutValidator {
  static bool validateWorkoutName(String name) {
    if (name.isEmpty) {
      return false;
    }
    if (name.length < 2) return false;
    if (name.length > 50) return false;
    return true;
  }

  static bool validateWorkoutDescription(String description) {
    if (description.length > 200) return false;
    return true;
  }

  String? validateWorkout(Workout workout) {
    if (!validateWorkoutName(workout.name)) {
      return workout.name.isEmpty
          ? 'O nome do treino é obrigatório'
          : 'O nome deve ter entre 2 e 50 caracteres';
    }

    if (!validateWorkoutDescription(workout.description)) {
      return 'A descrição deve ter no máximo 200 caracteres';
    }
    return null;
  }
}
