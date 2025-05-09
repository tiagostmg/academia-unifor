import 'package:academia_unifor/models/exercise.dart';

class ExerciseValidator {
  bool validateName(String name) {
    if (name.isEmpty) return false;
    if (name.length < 2) return false;
    if (name.length > 50) return false;
    return true;
  }

  bool validateReps(String reps) {
    if (reps.isEmpty) return false;
    if (reps.length > 20) return false;
    return true;
  }

  bool validateNotes(String? notes) {
    if (notes == null) return true;
    if (notes.length > 200) return false;
    return true;
  }

  bool validateWorkoutId(int workoutId) {
    return workoutId > 0;
  }

  String? validateExercise(Exercise exercise) {
    if (!validateName(exercise.name)) {
      return exercise.name.isEmpty
          ? 'O nome do exercício é obrigatório'
          : 'O nome deve ter entre 2 e 50 caracteres';
    }
    if (!validateReps(exercise.reps)) {
      return exercise.reps.isEmpty
          ? 'As repetições são obrigatórias'
          : 'As repetições devem ter no máximo 20 caracteres';
    }
    if (!validateNotes(exercise.notes)) {
      return 'As observações devem ter no máximo 200 caracteres';
    }
    if (!validateWorkoutId(exercise.workoutId)) {
      return 'ID do treino inválido';
    }
    return null;
  }
}
