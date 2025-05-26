class Classes {
  int id;
  String name;
  String type;
  String date;
  String time;
  String duration;
  int capacity;
  int teacherId;
  List<int> studentIds;

  Classes({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.time,
    required this.duration,
    required this.capacity,
    required this.teacherId,
    required this.studentIds,
  });

  factory Classes.fromJson(Map<String, dynamic> json) {
    return Classes(
      id: json['id'],
      name: json['class_name'],
      type: json['class_type'],
      date: json['class_date'],
      time: json['class_time'],
      duration: json['class_duration'],
      capacity: json['class_capacity'],
      teacherId: json['class_teacherId'],
      studentIds: List<int>.from(json['class_list_users_id'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': name,
      'class_type': type,
      'class_date': date,
      'class_time': time,
      'class_duration': duration,
      'class_capacity': capacity,
      'class_teacherId': teacherId,
      'class_list_users_id': studentIds,
    };
  }
}
