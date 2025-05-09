import 'package:flutter/material.dart';

class ValidatorUser {
  final BuildContext context;

  ValidatorUser(this.context);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool validateName(String name) {
    if (name.isEmpty) {
      _showMessage('O nome é obrigatório');
      return false;
    }
    if (name.length < 3) {
      _showMessage('O nome deve ter pelo menos 3 caracteres');
      return false;
    }
    if (name.length > 50) {
      _showMessage('O nome deve ter no máximo 50 caracteres');
      return false;
    }
    return true;
  }

  bool validatePhone(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedPhone.isEmpty) {
      _showMessage('O telefone é obrigatório');
      return false;
    }

    if (cleanedPhone.length < 10 || cleanedPhone.length > 11) {
      _showMessage(
        'Telefone inválido. Use (DDD) 9XXXX-XXXX ou (DDD) XXXX-XXXX',
      );
      return false;
    }

    return true;
  }

  bool validateAddress(String address) {
    if (address.isEmpty) {
      _showMessage('O endereço é obrigatório');
      return false;
    }
    if (address.length < 5) {
      _showMessage('O endereço deve ter pelo menos 5 caracteres');
      return false;
    }
    return true;
  }

  bool validateImageUrl(String url) {
    if (url.isEmpty) return true; // URL é opcional

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) {
      _showMessage('URL da imagem inválida');
      return false;
    }

    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    final hasValidExtension = allowedExtensions.any(
      (ext) => url.toLowerCase().endsWith(ext),
    );

    if (!hasValidExtension) {
      _showMessage('A URL deve terminar com .jpg, .jpeg, .png ou .gif');
      return false;
    }

    return true;
  }

  bool validateEmail(String email) {
    if (email.isEmpty) {
      _showMessage('O email é obrigatório');
      return false;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(email)) {
      _showMessage('Email inválido. Use o formato exemplo@dominio.com');
      return false;
    }

    return true;
  }

  bool validateBirthDate(String? date) {
    if (date == null || date.isEmpty) {
      _showMessage('A data de nascimento é obrigatória');
      return false;
    }
    return true;
  }
}
