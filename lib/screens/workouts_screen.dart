import 'package:academia_unifor/models/equipment.dart';
import 'package:academia_unifor/services/equipment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/models/users.dart';
import 'package:academia_unifor/models/exercise.dart';
import 'package:academia_unifor/services/user_provider.dart';
import 'package:academia_unifor/models/workout.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 1,
          child: const WorkoutsBody(),
        ),
      ),
    );
  }
}

class WorkoutsBody extends ConsumerWidget {
  const WorkoutsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Users? user = ref.watch(userProvider);

    if (user == null) {
      return const Center(child: Text("Nenhum usuário logado"));
    }

    final List<Workout> workouts = user.workouts;

    return Column(
      children: [
        Expanded(
          child: Scaffold(
            appBar: const SearchAppBar(),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  workouts.isEmpty
                      ? const Center(
                        child: Text(
                          "Você ainda não tem nenhum treino cadastrado",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return WorkoutCard(workout: workout);
                        },
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final Workout workout;

  const WorkoutCard({required this.workout, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.name,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              workout.description,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(204),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ExerciseTile(exercise: exercise),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseTile extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseTile({required this.exercise, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exerciseState = ref.watch(exerciseStateProvider);
    final isCompleted = exerciseState[exercise.name] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (value) {
              ref
                  .read(exerciseStateProvider.notifier)
                  .toggleExercise(exercise.name);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Reps: ${exercise.reps}",
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                if (exercise.equipmentId != null)
                  FutureBuilder<EquipmentItem?>(
                    future: EquipmentService().getEquipmentById(
                      exercise.equipmentId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text("Carregando equipamento..."),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text("Equipamento não encontrado"),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Equipamento: ${snapshot.data!.name}",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                      );
                    },
                  ),
                if (exercise.notes != null && exercise.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Notas: ${exercise.notes}",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseStateNotifier extends StateNotifier<Map<String, bool>> {
  ExerciseStateNotifier() : super({});

  void toggleExercise(String exerciseName) {
    state = {...state, exerciseName: !(state[exerciseName] ?? false)};
  }

  bool isCompleted(String exerciseName) {
    return state[exerciseName] ?? false;
  }
}

final exerciseStateProvider =
    StateNotifierProvider<ExerciseStateNotifier, Map<String, bool>>(
      (ref) => ExerciseStateNotifier(),
    );
