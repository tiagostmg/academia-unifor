class Exercise {
  final String name;
  final String reps;
  final List<String> muscles;
  final String equipment;
  final String type;
  final String level;
  final String notes;

  Exercise({
    required this.name,
    required this.reps,
    required this.muscles,
    required this.equipment,
    required this.type,
    required this.level,
    required this.notes,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      reps: json['reps'],
      muscles: List<String>.from(json['muscles']),
      equipment: json['equipment'],
      type: json['type'],
      level: json['level'],
      notes: json['notes'],
    );
  }
}
