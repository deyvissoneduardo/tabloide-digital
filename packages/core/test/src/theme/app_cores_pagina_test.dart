import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

const _primaria = AppCores.primaria;
const _secundaria = AppCores.secundaria;

/// Tabela obrigatória de plano.md §4.7 (idêntica à do React).
const _casos = <(String?, Color, String)>[
  ('#C8102E', _primaria, '#C8102E'),
  ('#FFD100', _secundaria, '#8A7100'),
  (null, _primaria, '#1565C0'),
  (null, _secundaria, '#996B00'),
  ('#FFFFFF', _primaria, '#757575'),
  ('#000000', _primaria, '#000000'),
  ('#00FF00', _primaria, '#008A00'),
  ('#1565C0', _primaria, '#1565C0'),
  ('#ffd100', _secundaria, '#996B00'),
];

void main() {
  group('Funcionalidade: Cor de texto da página (plano §4.7)', () {
    for (final (entrada, padrao, esperado) in _casos) {
      test(
        'Cenário: Dado $entrada com padrão ${AppCoresPagina.paraHex(padrao)}, então a cor é $esperado',
        () {
          expect(
            AppCoresPagina.paraHex(AppCoresPagina.corDeTexto(entrada, padrao)),
            esperado,
          );
        },
      );
    }

    test('Cenário: Dado cada caso da tabela, então toda saída tem contraste ≥ 4,5 com branco', () {
      for (final (entrada, padrao, _) in _casos) {
        expect(
          AppTheme.contraste(
            AppCoresPagina.corDeTexto(entrada, padrao),
            const Color(0xFFFFFFFF),
          ),
          greaterThanOrEqualTo(4.5),
          reason: '$entrada',
        );
      }
    });

    test('Cenário: Dado a identidade sem cores, então primária e secundária são os padrões do Tabloide ajustados', () {
      final cores = AppCoresPagina.de();

      expect(AppCoresPagina.paraHex(cores.primaria), '#1565C0');
      expect(AppCoresPagina.paraHex(cores.secundaria), '#996B00');
    });
  });
}
