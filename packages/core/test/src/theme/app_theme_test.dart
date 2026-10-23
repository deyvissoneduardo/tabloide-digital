import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: tema derivado da marca', () {
    const marcas = {
      'azul e âmbar': MarcaFake(),
      'vermelha e verde': MarcaFake(
        corPrimaria: Color(0xFFC62828),
        corSecundaria: Color(0xFF2E7D32),
      ),
      'amarela clara e rosa': MarcaFake(
        corPrimaria: Color(0xFFFFEB3B),
        corSecundaria: Color(0xFFF8BBD0),
      ),
    };

    for (final MapEntry(key: nome, value: marca) in marcas.entries) {
      group('Cenário: Dado a marca $nome', () {
        test('Quando gero o tema claro, então é Material 3 e claro', () {
          final tema = AppTheme.claro(marca);
          expect(tema.useMaterial3, isTrue);
          expect(tema.colorScheme.brightness, Brightness.light);
        });

        test('Quando gero os temas, então a primária e a secundária são de famílias diferentes', () {
          final esquema = AppTheme.claro(marca).colorScheme;
          expect(esquema.primary, isNot(esquema.secondary));
        });

        if (marca.corPrimaria.computeLuminance() < 0.5) {
          test('Quando gero o tema claro, então a primária é exatamente a cor da marca', () {
            expect(
              AppTheme.claro(marca).colorScheme.primary,
              marca.corPrimaria,
            );
          });
        } else {
          // Cor muito clara não dá contraste com branco: o tema usa a cor
          // exata com texto preto ou, sem contraste, um tom mais escuro.
          test(
            'Quando gero o tema claro, então o texto sobre a primária é preto',
            () {
              expect(
                AppTheme.claro(marca).colorScheme.onPrimary,
                const Color(0xFF000000),
              );
            },
          );
        }

        test('Quando gero o tema claro, então texto sobre primária, secundária e erro tem contraste >= 4.5 (RNF10)', () {
          final e = AppTheme.claro(marca).colorScheme;
          for (final (fundo, texto) in [
            (e.primary, e.onPrimary),
            (e.secondary, e.onSecondary),
            (e.error, e.onError),
            (e.surface, e.onSurface),
            (e.surface, e.onSurfaceVariant),
          ]) {
            expect(AppTheme.contraste(fundo, texto), greaterThanOrEqualTo(4.5));
          }
        });
      });
    }

    group('Cenário: Dado qualquer marca, quando gero o tema claro', () {
      final tema = AppTheme.claro(const MarcaFake());

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

    test('Cenário: Dado qualquer marca, quando gero o tema claro, então o erro é o de AppCores', () {
      expect(
        AppTheme.claro(const MarcaFake()).colorScheme.error,
        AppCores.erro,
      );
    });
  });
}
