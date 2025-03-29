import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/equipment.dart';

Future<List<EquipmentCategory>> loadGymEquipment() async {
  final jsonStr = await rootBundle.loadString('assets/mocks/gymEquipment.json');
  final data = json.decode(jsonStr);
  final categories = data['gymEquipment'] as List;

  return categories.map((e) => EquipmentCategory.fromJson(e)).toList();
}
