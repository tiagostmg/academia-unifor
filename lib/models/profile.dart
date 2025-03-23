class Profile {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String birthDate;
  final String avatarUrl;

  Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      birthDate: json['birthDate'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
