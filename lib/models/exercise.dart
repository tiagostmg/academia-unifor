class Exercise {
  String name;
  String reps;

  Exercise({required this.name, required this.reps});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(name: json['name'], reps: json['reps']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'reps': reps};
  }
}
