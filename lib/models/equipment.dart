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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'quantity': quantity,
      'image': image,
      'operational': operational,
    };
  }
}
