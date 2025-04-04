class EquipmentItem {
  String name;
  String brand;
  String model;
  int quantity;
  String image;
  bool operational;

  EquipmentItem({
    required this.name,
    required this.brand,
    required this.model,
    required this.quantity,
    required this.image,
    required this.operational,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
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
  String category;
  int total;
  List<EquipmentItem> items;

  EquipmentCategory({
    required this.category,
    required this.total,
    required this.items,
  });

  factory EquipmentCategory.fromJson(Map<String, dynamic> json) {
    return EquipmentCategory(
      category: json['category'],
      total: json['total'],
      items:
          (json['items'] as List)
              .map((item) => EquipmentItem.fromJson(item))
              .toList(),
    );
  }
}
