import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/profile.dart';

class ProfileService {
  Future<Profile> loadProfile() async {
    final data = await rootBundle.loadString('assets/mocks/profile.json');
    final jsonResult = json.decode(data);
    return Profile.fromJson(jsonResult);
  }
}
