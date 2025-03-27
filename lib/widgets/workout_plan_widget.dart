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

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _exercises.length.clamp(
              0,
              10,
            ), // mostra no máx. 10 exercícios
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return _ExerciseCard(exercise: exercise);
            },
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(exercise.reps, style: theme.textTheme.bodySmall),
          const Spacer(),
          Text('Nível: ${exercise.level}', style: theme.textTheme.bodySmall),
          Text('Tipo: ${exercise.type}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
