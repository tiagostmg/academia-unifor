// import 'dart:math';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../models/exercise.dart';

// class WorkoutPlanWidget extends StatefulWidget {
//   const WorkoutPlanWidget({super.key});

//   @override
//   State<WorkoutPlanWidget> createState() => _WorkoutPlanWidgetState();
// }

// class _WorkoutPlanWidgetState extends State<WorkoutPlanWidget> {
//   List<Exercise> _exercises = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadExercises();
//   }

//   Future<void> _loadExercises() async {
//     final String response = await rootBundle.loadString(
//       'assets/mocks/exercises.json',
//     );
//     final data = json.decode(response);
//     final List<dynamic> exercisesJson = data['exercises'];

//     setState(() {
//       _exercises = exercisesJson.map((e) => Exercise.fromJson(e)).toList();
//     });
//   }

//   Map<String, List<Exercise>> _splitByWorkoutDays(List<Exercise> all) {
//     final treinoA = <Exercise>[];
//     final treinoB = <Exercise>[];
//     final treinoC = <Exercise>[];

//     for (var ex in all) {
//       final muscles = ex.muscles.join().toLowerCase();

//       if (muscles.contains('peitoral') ||
//           muscles.contains('tríceps') ||
//           muscles.contains('deltoide')) {
//         treinoA.add(ex);
//       } else if (muscles.contains('dorsal') ||
//           muscles.contains('bíceps') ||
//           muscles.contains('trapézio')) {
//         treinoB.add(ex);
//       } else if (muscles.contains('quadríceps') ||
//           muscles.contains('glúteo') ||
//           muscles.contains('posterior') ||
//           muscles.contains('abdômen') ||
//           muscles.contains('panturrilha')) {
//         treinoC.add(ex);
//       }
//     }

//     final random = Random();

//     treinoA.shuffle();
//     treinoB.shuffle();
//     treinoC.shuffle();

//     int randomAmount(List<Exercise> list) =>
//         list.length < 6
//             ? list.length
//             : 6 + random.nextInt(min(5, list.length - 6) + 1);

//     return {
//       'Treino A': treinoA.take(randomAmount(treinoA)).toList(),
//       'Treino B': treinoB.take(randomAmount(treinoB)).toList(),
//       'Treino C': treinoC.take(randomAmount(treinoC)).toList(),
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_exercises.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final groupedExercises = _splitByWorkoutDays(_exercises);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     Color getCardColor(String treino) {
//       switch (treino) {
//         case 'Treino A':
//           return isDark ? Colors.orange.shade300 : Colors.orange.shade100;
//         case 'Treino B':
//           return isDark ? Colors.green.shade400 : Colors.green.shade100;
//         case 'Treino C':
//           return isDark ? Colors.blue.shade400 : Colors.blue.shade100;
//         default:
//           return isDark ? Colors.grey.shade700 : Colors.grey.shade200;
//       }
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'Plano de Treino',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//         ),
//         const SizedBox(height: 10),
//         ...groupedExercises.entries.map((entry) {
//           final titleWithCount = '${entry.key} (${entry.value.length})';
//           return _WorkoutGroup(
//             title: titleWithCount,
//             exercises: entry.value,
//             cardColor: getCardColor(entry.key),
//           );
//         }),
//       ],
//     );
//   }
// }

// class _WorkoutGroup extends StatelessWidget {
//   final String title;
//   final List<Exercise> exercises;
//   final Color cardColor;

//   const _WorkoutGroup({
//     required this.title,
//     required this.exercises,
//     required this.cardColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (exercises.isEmpty) return const SizedBox();

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(title, style: Theme.of(context).textTheme.titleMedium),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 150,
//             child: ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               scrollDirection: Axis.horizontal,
//               itemCount: exercises.length.clamp(0, 10),
//               separatorBuilder: (_, __) => const SizedBox(width: 10),
//               itemBuilder: (context, index) {
//                 return _ExerciseCard(
//                   exercise: exercises[index],
//                   backgroundColor: cardColor,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ExerciseCard extends StatefulWidget {
//   final Exercise exercise;
//   final Color backgroundColor;

//   const _ExerciseCard({required this.exercise, required this.backgroundColor});

//   @override
//   State<_ExerciseCard> createState() => _ExerciseCardState();
// }

// class _ExerciseCardState extends State<_ExerciseCard> {
//   bool isDone = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final isDark =
//         ThemeData.estimateBrightnessForColor(widget.backgroundColor) ==
//         Brightness.dark;

//     final textColor = isDark ? Colors.white : Colors.black;
//     final repsBackground = isDark ? Colors.black : Colors.white;
//     final repsTextColor = isDark ? Colors.white : Colors.black;

//     final cardWidth = widget.exercise.reps.length > 10 ? 220.0 : 180.0;

//     return Container(
//       width: cardWidth,
//       decoration: BoxDecoration(
//         color: widget.backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
//       ),
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Título + ícone
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Text(
//                   widget.exercise.name,
//                   style: theme.textTheme.labelLarge?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: textColor,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     isDone = !isDone;
//                   });
//                 },
//                 child: Icon(
//                   isDone ? Icons.check_circle : Icons.radio_button_unchecked,
//                   color: isDone ? Colors.black : textColor.withAlpha(120),
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Nível e tipo
//           Text(
//             'Nível: ${widget.exercise.level}',
//             style: theme.textTheme.bodySmall?.copyWith(
//               fontSize: 12,
//               color: textColor,
//             ),
//           ),
//           Text(
//             'Tipo: ${widget.exercise.type}',
//             style: theme.textTheme.bodySmall?.copyWith(
//               fontSize: 12,
//               color: textColor,
//             ),
//           ),

//           const Spacer(),

//           // Badge de repetições
//           Row(
//             children: [
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: repsBackground,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: repsTextColor.withAlpha(100)),
//                 ),
//                 child: Text(
//                   widget.exercise.reps,
//                   style: TextStyle(
//                     color: repsTextColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
