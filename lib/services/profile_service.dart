import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/users.dart';

class UsersService {
  Future<Users> loadUsers() async {
    final data = await rootBundle.loadString('assets/mocks/users.json');
    final jsonResult = json.decode(data);
    return Users.fromJson(jsonResult);
  }
}
