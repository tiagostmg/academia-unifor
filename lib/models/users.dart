import 'package:academia_unifor/models/workout.dart';

class Users {
  final int id;
  String name;
  String email;
  String password;
  String phone;
  String address;
  String? birthDate;
  String avatarUrl;
  bool isAdmin;
  List<Workout> workouts;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    this.birthDate,
    required this.avatarUrl,
    required this.isAdmin,
    required this.workouts,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '',
      phone: json['phone'],
      address: json['address'],
      birthDate: json['birthDate'],
      avatarUrl: json['avatarUrl'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      workouts:
          (json['workouts'] as List<dynamic>?)
              ?.map((w) => Workout.fromJson(w))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'birthDate': birthDate,
      'avatarUrl': avatarUrl,
      'isAdmin': isAdmin ? true : null,
      'workouts': workouts.map((w) => w.toJson()).toList(),
    };
  }
}
