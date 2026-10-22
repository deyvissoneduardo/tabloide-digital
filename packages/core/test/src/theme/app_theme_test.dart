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

        test('Quando gero o tema escuro, então o brilho é escuro', () {
          expect(
            AppTheme.escuro(marca).colorScheme.brightness,
            Brightness.dark,
          );
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

        for (final (brilho, gerar) in [
          ('claro', AppTheme.claro),
          ('escuro', AppTheme.escuro),
        ]) {
          test(
            'Quando gero o tema $brilho, então texto sobre primária e secundária tem contraste >= 4.5 (RNF10)',
            () {
              final e = gerar(marca).colorScheme;
              expect(
                AppTheme.contraste(e.primary, e.onPrimary),
                greaterThanOrEqualTo(4.5),
              );
              expect(
                AppTheme.contraste(e.secondary, e.onSecondary),
                greaterThanOrEqualTo(4.5),
              );
            },
          );
        }
      });
    }

    test('Cenário: Dado qualquer marca, quando gero o tema claro, então o erro é o de AppCores', () {
      expect(
        AppTheme.claro(const MarcaFake()).colorScheme.error,
        AppCores.erro,
      );
    });
  });
}
