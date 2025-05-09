import 'package:academia_unifor/models/equipment.dart';

class EquipmentValidator {
  bool validateName(String name) {
    if (name.isEmpty) return false;
    if (name.length < 2) return false;
    if (name.length > 50) return false;
    return true;
  }

  bool validateBrand(String brand) {
    if (brand.isEmpty) return false;
    if (brand.length < 2) return false;
    if (brand.length > 30) return false;
    return true;
  }

  bool validateModel(String model) {
    if (model.isEmpty) return false;
    if (model.length < 2) return false;
    if (model.length > 30) return false;
    return true;
  }

  bool validateQuantity(int quantity) {
    if (quantity < 0) return false;
    if (quantity > 999) return false;
    return true;
  }

  bool validateImageUrl(String url) {
    if (url.isEmpty) return true;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) return false;

    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return allowedExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  bool validateCategoryId(int categoryId) {
    return categoryId > 0;
  }

  String? validateEquipment(EquipmentItem equipment) {
    if (!validateName(equipment.name)) {
      return equipment.name.isEmpty
          ? 'O nome do equipamento é obrigatório'
          : 'O nome deve ter entre 2 e 50 caracteres';
    }
    if (!validateBrand(equipment.brand)) {
      return equipment.brand.isEmpty
          ? 'A marca é obrigatória'
          : 'A marca deve ter entre 2 e 30 caracteres';
    }
    if (!validateModel(equipment.model)) {
      return equipment.model.isEmpty
          ? 'O modelo é obrigatório'
          : 'O modelo deve ter entre 2 e 30 caracteres';
    }
    if (!validateQuantity(equipment.quantity)) {
      return 'A quantidade deve ser entre 0 e 999';
    }
    if (!validateImageUrl(equipment.image)) {
      return 'URL da imagem inválida (use .jpg, .jpeg, .png, .gif ou .webp)';
    }
    if (!validateCategoryId(equipment.categoryId)) {
      return 'Selecione uma categoria válida';
    }
    return null;
  }
}
