import 'package:flutter/material.dart';

Future<bool?> confirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final theme = Theme.of(context);

  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Cor de fundo
                foregroundColor: theme.colorScheme.onPrimary, // Cor do texto
              ),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Cor de fundo
                foregroundColor: theme.colorScheme.onPrimary, // Cor do texto
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
  );
}
