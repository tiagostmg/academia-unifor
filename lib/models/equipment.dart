class EquipmentItem {
  int id;
  int categoryId;
  String name;
  String brand;
  String model;
  int quantity;
  String image;
  bool operational;
  int quantityInUse;

  EquipmentItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.brand,
    required this.model,
    required this.quantity,
    required this.image,
    required this.operational,
    required this.quantityInUse,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      quantity: json['quantity'],
      image: json['image'] ?? '',
      operational: json['operational'] ?? true,
      quantityInUse: json['quantityInUse'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'brand': brand,
      'model': model,
      'quantity': quantity,
      'image': image,
      'operational': operational,
      'quantityInUse': quantityInUse,
    };
  }
}
