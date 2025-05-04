import 'package:academia_unifor/models.dart';

class EquipmentCategory {
  int id;
  String category;
  int total;
  List<EquipmentItem> items;

  EquipmentCategory({
    required this.id,
    required this.category,
    required this.total,
    required this.items,
  });

  factory EquipmentCategory.fromJson(Map<String, dynamic> json) {
    return EquipmentCategory(
      id: json['id'],
      category: json['category_name'] ?? '',
      total: json['total'],
      items:
          (json['equipments'] as List)
              .map((item) => EquipmentItem.fromJson(item))
              .toList(),
    );
  }
}
