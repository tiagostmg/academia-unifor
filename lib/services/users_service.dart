import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:academia_unifor/models/users.dart';

class UsersService {
  Future<List<Users>> loadUsers() async {
    final jsonStr = await rootBundle.loadString('assets/mocks/users.json');
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => Users.fromJson(e)).toList();
  }
}
