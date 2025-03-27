import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';

class WorkoutPlanWidget extends StatefulWidget {
  const WorkoutPlanWidget({super.key});

  @override
  State<WorkoutPlanWidget> createState() => _WorkoutPlanWidgetState();
}

class _WorkoutPlanWidgetState extends State<WorkoutPlanWidget> {
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final String response = await rootBundle.loadString(
      'assets/mocks/exercises.json',
    );
    final data = json.decode(response);
    final List<dynamic> exercisesJson = data['exercises'];

    setState(() {
      _exercises = exercisesJson.map((e) => Exercise.fromJson(e)).toList();
    });
  }

  Map<String, List<Exercise>> _splitByWorkoutDays(List<Exercise> all) {
    final treinoA = <Exercise>[];
    final treinoB = <Exercise>[];
    final treinoC = <Exercise>[];

    for (var ex in all) {
      final muscles = ex.muscles.join().toLowerCase();

      if (muscles.contains('peitoral') ||
          muscles.contains('tríceps') ||
          muscles.contains('deltoide')) {
        treinoA.add(ex);
      } else if (muscles.contains('dorsal') ||
          muscles.contains('bíceps') ||
          muscles.contains('trapézio')) {
        treinoB.add(ex);
      } else if (muscles.contains('quadríceps') ||
          muscles.contains('glúteo') ||
          muscles.contains('posterior') ||
          muscles.contains('abdômen') ||
          muscles.contains('panturrilha')) {
        treinoC.add(ex);
      }
    }

    return {'Treino A': treinoA, 'Treino B': treinoB, 'Treino C': treinoC};
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final groupedExercises = _splitByWorkoutDays(_exercises);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Plano de Treino',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 10),
        ...groupedExercises.entries.map((entry) {
          final color = switch (entry.key) {
            'Treino A' => Colors.orange.shade100,
            'Treino B' => Colors.green.shade100,
            'Treino C' => Colors.blue.shade100,
            _ => Colors.grey.shade200,
          };

          return _WorkoutGroup(
            title: entry.key,
            exercises: entry.value,
            cardColor: color,
          );
        }),
      ],
    );
  }
}

class _WorkoutGroup extends StatelessWidget {
  final String title;
  final List<Exercise> exercises;
  final Color cardColor;

  const _WorkoutGroup({
    required this.title,
    required this.exercises,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: exercises.length.clamp(0, 10),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _ExerciseCard(
                  exercise: exercises[index],
                  backgroundColor: cardColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Color backgroundColor;

  const _ExerciseCard({required this.exercise, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(exercise.reps, style: theme.textTheme.bodySmall),
          const Spacer(),
          Text(
            'Nível: ${exercise.level}',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
          Text(
            'Tipo: ${exercise.type}',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
