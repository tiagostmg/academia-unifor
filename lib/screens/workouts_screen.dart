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
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: CustomAppBar(),
            body: const WorkoutsBody(),
          ),
        ),
      ),
    );
  }
}

class WorkoutsBody extends ConsumerWidget {
  const WorkoutsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final Users? user = ref.watch(userProvider);

    if (user == null) {
      return Center(
        child: Text("Nenhum usuário logado", style: theme.textTheme.bodyLarge),
      );
    }

    final List<Workout> workouts = List.from(user.workouts)
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                workouts.isEmpty
                    ? Center(
                      child: Text(
                        "Você ainda não tem nenhum treino cadastrado",
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                    : ListView.separated(
                      itemCount: workouts.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        return ExpandableWorkoutCard(workout: workout);
                      },
                    ),
          ),
        ),
      ],
    );
  }
}

class ExpandableWorkoutCard extends ConsumerStatefulWidget {
  final Workout workout;

  const ExpandableWorkoutCard({required this.workout, super.key});

  @override
  ConsumerState<ExpandableWorkoutCard> createState() =>
      _ExpandableWorkoutCardState();
}

class _ExpandableWorkoutCardState extends ConsumerState<ExpandableWorkoutCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho do treino (sempre visível)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.workout.name,
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            if (widget.workout.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.workout.description,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: colorScheme.onPrimary.withAlpha(230),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: colorScheme.onPrimary,
                        size: 32,
                      ),
                    ],
                  ),
                ),

                // Conteúdo expandível (exercícios)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState:
                      _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...widget.workout.exercises.map(
                          (exercise) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExerciseTile(exercise: exercise),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    final colorScheme = theme.colorScheme;
    final exerciseState = ref.watch(exerciseStateProvider);
    final isCompleted = exerciseState[exercise.name] ?? false;

    return InkWell(
      onTap: () {
        ref.read(exerciseStateProvider.notifier).toggleExercise(exercise.name);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isCompleted
                  ? colorScheme.tertiaryContainer
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted ? colorScheme.tertiary : colorScheme.tertiary,
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isCompleted ? Colors.blue : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle_outlined,
                color: isCompleted ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildInfoChip(context, Icons.repeat, exercise.reps),
                  if (exercise.equipmentId != null)
                    FutureBuilder<EquipmentItem?>(
                      future: EquipmentService().getEquipmentById(
                        exercise.equipmentId!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Carregando equipamento...",
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                snapshot.data!.name,
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (exercise.notes != null && exercise.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        exercise.notes!,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurface.withAlpha(153),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurface),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
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
