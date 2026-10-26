import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_cores.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';
import 'package:tabloide_core/src/theme/app_tipografia.dart';

abstract final class AppTheme {
  static ThemeData claro() {
    final esquema = _esquema();
    final base = ThemeData(useMaterial3: true, colorScheme: esquema);
    final texto = AppTipografia.aplicar(base.textTheme);
    return base.copyWith(
      textTheme: texto,
      scaffoldBackgroundColor: esquema.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppEspacamentos.md,
        shape: Border(bottom: BorderSide(color: esquema.outlineVariant)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: AppEspacamentos.sm),
        color: esquema.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRaios.bordaMd,
          side: BorderSide(color: esquema.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppEspacamentos.md,
          vertical: AppEspacamentos.md,
        ),
        border: _borda(esquema.outline),
        enabledBorder: _borda(esquema.outline),
        focusedBorder: _borda(esquema.primary, largura: 2),
        errorBorder: _borda(esquema.error),
        focusedErrorBorder: _borda(esquema.error, largura: 2),
        disabledBorder: _borda(esquema.outlineVariant),
        errorMaxLines: 2,
        helperMaxLines: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(style: _botao(texto)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _botao(texto)),
      textButtonTheme: TextButtonThemeData(style: _botao(texto)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _botao(texto)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRaios.bordaLg),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRaios.bordaSm),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRaios.bordaLg),
        titleTextStyle: texto.titleLarge?.copyWith(color: esquema.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRaios.lg),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRaios.bordaSm),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppEspacamentos.md),
        minVerticalPadding: AppEspacamentos.sm,
      ),
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: esquema.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: esquema.surface,
        indicatorColor: esquema.secondaryContainer,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: esquema.primary,
      ),
    );
  }

  static OutlineInputBorder _borda(Color cor, {double largura = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRaios.bordaMd,
        borderSide: BorderSide(color: cor, width: largura),
      );

  static ButtonStyle _botao(TextTheme texto) => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(
      Size(AppLayout.alvoMinimo, AppLayout.alvoMinimo),
    ),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: AppEspacamentos.lg),
    ),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRaios.bordaPilula),
    ),
    textStyle: WidgetStatePropertyAll(texto.labelLarge),
  );

  static ColorScheme _esquema() {
    final daPrimaria = _daSemente(AppCores.primaria);
    final daSecundaria = _daSemente(AppCores.secundaria);
    var esquema = daPrimaria.copyWith(
      secondary: daSecundaria.primary,
      onSecondary: daSecundaria.onPrimary,
      secondaryContainer: daSecundaria.primaryContainer,
      onSecondaryContainer: daSecundaria.onPrimaryContainer,
      error: AppCores.erro,
    );
    final primaria = _corExata(AppCores.primaria);
    if (primaria != null) {
      esquema = esquema.copyWith(primary: primaria.$1, onPrimary: primaria.$2);
    }
    final secundaria = _corExata(AppCores.secundaria);
    if (secundaria != null) {
      esquema = esquema.copyWith(
        secondary: secundaria.$1,
        onSecondary: secundaria.$2,
      );
    }
    return esquema;
  }

  static const contrasteMinimo = 4.5;

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

  static double contraste(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final (claro, escuro) = la > lb ? (la, lb) : (lb, la);
    return (claro + 0.05) / (escuro + 0.05);
  }

  static ColorScheme _daSemente(Color semente) => ColorScheme.fromSeed(
    seedColor: semente,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
}
