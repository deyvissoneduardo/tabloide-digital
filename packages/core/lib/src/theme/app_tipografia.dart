import 'package:flutter/material.dart';

/// Ajustes de tipografia sobre o `TextTheme` do Material 3.
abstract final class AppTipografia {
  /// Aplica os pesos do painel ao [base] já colorido pelo tema.
  static TextTheme aplicar(TextTheme base) => base.copyWith(
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );
}
