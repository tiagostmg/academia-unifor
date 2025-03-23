class EquipmentItem {
  final String name;
  final String brand;
  final String model;
  final int quantity;
  final String image;

  EquipmentItem({
    required this.name,
    required this.brand,
    required this.model,
    required this.quantity,
    required this.image,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      quantity: json['quantity'],
      image: json['image'] ?? '',
    );
  }
}

class EquipmentCategory {
  final String category;
  final int total;
  final List<EquipmentItem> items;

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
