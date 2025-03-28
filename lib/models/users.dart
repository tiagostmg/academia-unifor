class Users {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String birthDate;
  final String avatarUrl;

  Users({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.avatarUrl,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      birthDate: json['birthDate'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
