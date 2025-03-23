import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exercise.dart';

Future<List<Exercise>> loadExercises() async {
  final jsonStr = await rootBundle.loadString('assets/mocks/exercises.json');
  final data = json.decode(jsonStr);
  final items = data['exercises'] as List;

  return items.map((e) => Exercise.fromJson(e)).toList();
}
