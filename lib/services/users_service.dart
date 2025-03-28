import 'dart:convert';
import 'package:academia_unifor/models/users.dart';
import 'package:flutter/services.dart';

class UsersService {
  Future<List<User>> loadUsers() async {
    final jsonStr = await rootBundle.loadString('assets/mocks/users.json');
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => User.fromJson(e)).toList();
  }
}
