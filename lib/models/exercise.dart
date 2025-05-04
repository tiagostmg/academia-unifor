class Exercise {
  int id;
  int workoutId;
  String name;
  String reps;
  String? notes;
  int? equipmentId;

  Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.reps,
    this.notes, // Permitir que seja nulo
    this.equipmentId,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      workoutId: json['workoutId'],
      name: json['name'],
      reps: json['reps'],
      notes: json['notes'],
      equipmentId: json['equipmentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'name': name, 
      'reps': reps, 
      if (notes != null) 'notes': notes,
      if (equipmentId != null) 'equipmentId': equipmentId,};
  }
}
