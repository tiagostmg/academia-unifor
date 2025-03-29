class Exercise {
  String name;
  String reps;
  List<String> muscles;
  String equipment;
  String type;
  String level;
  String notes;
  String image;

  Exercise({
    required this.name,
    required this.reps,
    required this.muscles,
    required this.equipment,
    required this.type,
    required this.level,
    required this.notes,
    required this.image,
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
      image: json['image'] ?? '',
    );
  }
}
