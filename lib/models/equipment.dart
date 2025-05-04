class EquipmentItem {
  int id;
  String name;
  String brand;
  String model;
  int quantity;
  String image;
  bool operational;

  EquipmentItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.quantity,
    required this.image,
    required this.operational,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      quantity: json['quantity'],
      image: json['image'] ?? '',
      operational: json['operational'] ?? true,
    );
  }
}

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
