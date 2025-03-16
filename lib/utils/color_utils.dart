import 'package:flutter/material.dart';

/// Escurece uma cor reduzindo sua luminosidade.
///
/// O parâmetro [amount] deve estar entre 0.0 (sem mudança) e 1.0 (totalmente preto).
Color darken(Color color, [double amount = 0.2]) {
  assert(
    amount >= 0 && amount <= 1,
    'O valor de amount deve estar entre 0 e 1',
  );

  final hsl = HSLColor.fromColor(color);
  final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return darkened.toColor();
}
