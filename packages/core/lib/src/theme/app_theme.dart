import 'package:flutter/material.dart';
import 'package:tabloide_core/src/brand/brand_config.dart';
import 'package:tabloide_core/src/theme/app_cores.dart';
import 'package:tabloide_core/src/theme/app_tipografia.dart';

/// Tema do painel calculado a partir da marca do cliente.
abstract final class AppTheme {
  /// Tema claro da [marca].
  static ThemeData claro(BrandConfig marca) => _tema(marca, Brightness.light);

  /// Tema escuro da [marca].
  static ThemeData escuro(BrandConfig marca) => _tema(marca, Brightness.dark);

  static ThemeData _tema(BrandConfig marca, Brightness brilho) {
    final daPrimaria = _esquema(marca.corPrimaria, brilho);
    // A secundária vem de um esquema próprio: passar a cor crua em
    // `secondary:` não recalcula o onSecondary.
    final daSecundaria = _esquema(marca.corSecundaria, brilho);
    var esquema = daPrimaria.copyWith(
      secondary: daSecundaria.primary,
      onSecondary: daSecundaria.onPrimary,
      secondaryContainer: daSecundaria.primaryContainer,
      onSecondaryContainer: daSecundaria.onPrimaryContainer,
    );
    if (brilho == Brightness.light) {
      esquema = esquema.copyWith(error: AppCores.erro);
      // No claro, o cliente vê a cor exata dele sempre que ela tiver
      // contraste com branco ou preto; senão fica o tom calculado.
      final primaria = _corExata(marca.corPrimaria);
      if (primaria != null) {
        esquema = esquema.copyWith(
          primary: primaria.$1,
          onPrimary: primaria.$2,
        );
      }
      final secundaria = _corExata(marca.corSecundaria);
      if (secundaria != null) {
        esquema = esquema.copyWith(
          secondary: secundaria.$1,
          onSecondary: secundaria.$2,
        );
      }
    }
    final tema = ThemeData(useMaterial3: true, colorScheme: esquema);
    return tema.copyWith(textTheme: AppTipografia.aplicar(tema.textTheme));
  }

  /// Contraste mínimo de texto normal (WCAG AA).
  static const contrasteMinimo = 4.5;

  /// [cor] com o texto (branco ou preto) de maior contraste, ou `null` se
  /// nenhum dos dois atingir [contrasteMinimo].
  static (Color, Color)? _corExata(Color cor) {
    final sobreBranco = contraste(cor, _branco);
    final sobrePreto = contraste(cor, _preto);
    final (texto, valor) = sobreBranco >= sobrePreto
        ? (_branco, sobreBranco)
        : (_preto, sobrePreto);
    return valor >= contrasteMinimo ? (cor, texto) : null;
  }

  static const _branco = Color(0xFFFFFFFF);
  static const _preto = Color(0xFF000000);

  /// Razão de contraste WCAG entre duas cores opacas.
  static double contraste(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final (claro, escuro) = la > lb ? (la, lb) : (lb, la);
    return (claro + 0.05) / (escuro + 0.05);
  }

  // fidelity mantém o tom perto da cor do cliente; o padrão (tonalSpot)
  // dessatura.
  static ColorScheme _esquema(Color semente, Brightness brilho) =>
      ColorScheme.fromSeed(
        seedColor: semente,
        brightness: brilho,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );
}
