import 'package:flutter/painting.dart';

/// Cores que não são da marca: iguais para todo cliente.
abstract final class AppCores {
  /// Erros e ações destrutivas.
  static const erro = Color(0xFFB3261E);

  /// Confirmações.
  static const sucesso = Color(0xFF2E7D32);

  /// Avisos.
  static const alerta = Color(0xFFED6C02);

  /// Fundo neutro claro.
  static const neutroClaro = Color(0xFFF5F5F5);

  /// Fundo neutro escuro.
  static const neutroEscuro = Color(0xFF1C1B1F);
}
