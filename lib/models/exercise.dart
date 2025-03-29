class Exercise {
  String name;
  String reps;
  String? notes;

  Exercise({
    required this.name,
    required this.reps,
    this.notes, // Permitir que seja nulo
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      reps: json['reps'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'reps': reps, if (notes != null) 'notes': notes};
  }
}
