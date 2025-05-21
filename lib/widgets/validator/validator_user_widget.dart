import 'package:academia_unifor/models/users.dart';

class ValidatorUser {
  static bool validateName(String name) {
    if (name.isEmpty) {
      return false;
    }
    if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(name)) {
      return false;
    }
    if (name.length < 3) {
      return false;
    }
    if (name.length > 50) {
      return false;
    }
    return true;
  }

  static bool validatePhone(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedPhone.isEmpty) {
      return true;
    }
    if (cleanedPhone.length < 10 || cleanedPhone.length > 11) {
      return false;
    }
    return true;
  }

  static bool validateAddress(String address) {
    if (address.isEmpty) {
      return true;
    }
    if (address.length < 5) {
      return false;
    }
    return true;
  }

  static bool validateImageUrl(String url) {
    if (url.isEmpty) return true;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) {
      return false;
    }

    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    final hasValidExtension = allowedExtensions.any(
      (ext) => url.toLowerCase().endsWith(ext),
    );

    if (!hasValidExtension) {
      return false;
    }

    return true;
  }

  static bool validateEmail(String email) {
    if (email.isEmpty) {
      return false;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    return true;
  }

  static bool validatePassword(String password) {
    if (password.isEmpty) {
      return false;
    }
    if (password.length < 4) {
      return false;
    }
    if (password.length > 20) {
      return false;
    }
    return true;
  }

  static bool validateBirthDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return false;
    }

    // Tenta converter a string para DateTime para validação
    DateTime? date;
    try {
      // Assume formato DD/MM/YYYY
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          date = DateTime(
            int.parse(parts[2]), // ano
            int.parse(parts[1]), // mês
            int.parse(parts[0]), // dia
          );
        }
      }
      // Assume formato YYYY-MM-DD
      else if (dateStr.contains('-')) {
        date = DateTime.parse(dateStr);
      }
    } catch (e) {
      return false;
    }

    if (date == null) {
      return false;
    }

    final now = DateTime.now();
    final minDate = DateTime(now.year - 120, now.month, now.day);
    if (date.isBefore(minDate)) {
      return false;
    }

    return true;
  }

  String? validateUser(Users user) {
    if (!validateName(user.name)) {
      return user.name.isEmpty
          ? 'O nome é obrigatório'
          : 'O nome deve ter entre 3 e 50 caracteres e apenas letras';
    }
    if (!validatePhone(user.phone)) {
      return user.phone.isEmpty
          ? 'O telefone é obrigatório'
          : 'Telefone inválido. Use (DDD) 9XXXX-XXXX ou (DDD) XXXX-XXXX';
    }
    if (!validateAddress(user.address)) {
      return user.address.isEmpty
          ? 'O endereço é obrigatório'
          : 'O endereço deve ter pelo menos 5 caracteres';
    }
    if (!validateImageUrl(user.avatarUrl)) {
      return 'URL da imagem inválida (use .jpg, .jpeg, .png ou .gif)';
    }
    if (!validateEmail(user.email)) {
      return user.email.isEmpty
          ? 'O email é obrigatório'
          : 'Email inválido. Use o formato exemplo@dominio.com';
    }
    if (!validatePassword(user.password)) {
      return user.password.isEmpty
          ? 'A senha é obrigatória'
          : 'A senha deve ter entre 4 e 20 caracteres';
    }
    if (!validateBirthDate(user.birthDate)) {
      return user.birthDate == null
          ? 'A data de nascimento é obrigatória'
          : 'Data de nascimento inválida. Você deve ter entre 12 e 120 anos';
    }

    return null;
  }
}
