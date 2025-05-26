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
      name: json['className'],
      type: json['classType'],
      date: json['classDate'],
      time: json['classTime'],
      duration: json['classDuration'],
      capacity: json['classCapacity'],
      teacherId: json['teacherId'],
      studentIds: List<int>.from(json['userIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': name,
      'classType': type,
      'classDate': date,
      'classTime': time,
      'classDuration': duration,
      'classCapacity': capacity,
      'teacherId': teacherId,
      'userIds': studentIds,
    };
  }
}
