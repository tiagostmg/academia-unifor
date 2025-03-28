class Users {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String birthDate;
  final String avatarUrl;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.avatarUrl,
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
    };
  }
}
