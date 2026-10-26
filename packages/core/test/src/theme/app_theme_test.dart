import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: tema claro do painel', () {
    group('Cenário: Dado as cores do Tabloide', () {
      final esquema = AppTheme.claro().colorScheme;

      test('Quando gero o tema claro, então é Material 3 e claro', () {
        final tema = AppTheme.claro();
        expect(tema.useMaterial3, isTrue);
        expect(tema.colorScheme.brightness, Brightness.light);
      });

      test('Quando gero o tema, então a primária e a secundária são de famílias diferentes', () {
        expect(esquema.primary, isNot(esquema.secondary));
      });

      test('Quando gero o tema claro, então primária e secundária são exatamente as de AppCores', () {
        expect(esquema.primary, AppCores.primaria);
        expect(esquema.secondary, AppCores.secundaria);
      });

      test('Quando gero o tema claro, então texto sobre primária, secundária e erro tem contraste >= 4.5 (RNF10)', () {
        for (final (fundo, texto) in [
          (esquema.primary, esquema.onPrimary),
          (esquema.secondary, esquema.onSecondary),
          (esquema.error, esquema.onError),
          (esquema.surface, esquema.onSurface),
          (esquema.surface, esquema.onSurfaceVariant),
        ]) {
          expect(AppTheme.contraste(fundo, texto), greaterThanOrEqualTo(4.5));
        }
      });
    });

    group('Cenário: Dado o tema claro', () {
      final tema = AppTheme.claro();

      test('Então cards são planos, com borda e raio md', () {
        final card = tema.cardTheme;
        expect(card.elevation, 0);
        final forma = card.shape! as RoundedRectangleBorder;
        expect(forma.borderRadius, AppRaios.bordaMd);
        expect(forma.side.color, tema.colorScheme.outlineVariant);
      });

      test('Então campos têm contorno com raio md', () {
        final borda =
            tema.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
        expect(borda.borderRadius, AppRaios.bordaMd);
      });

      test('Então botões são pílula com alvo mínimo de 48', () {
        for (final estilo in [
          tema.filledButtonTheme.style!,
          tema.outlinedButtonTheme.style!,
          tema.textButtonTheme.style!,
        ]) {
          expect(
            estilo.shape!.resolve({}),
            const RoundedRectangleBorder(borderRadius: AppRaios.bordaPilula),
          );
          expect(estilo.minimumSize!.resolve({})!.height, AppLayout.alvoMinimo);
        }
      });

      test('Então dialogs têm raio lg e SnackBar é flutuante', () {
        expect(
          tema.dialogTheme.shape,
          const RoundedRectangleBorder(borderRadius: AppRaios.bordaLg),
        );
        expect(tema.snackBarTheme.behavior, SnackBarBehavior.floating);
      });
    });

    test('Cenário: Dado o tema claro, então o erro é o de AppCores', () {
      expect(AppTheme.claro().colorScheme.error, AppCores.erro);
    });
  });
}
