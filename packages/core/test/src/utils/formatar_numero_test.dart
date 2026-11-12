import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: formatar números em pt-BR', () {
    for (final (valor, texto) in [
      (0, '0'),
      (999, '999'),
      (1000, '1.000'),
      (12345, '12.345'),
      (1000000, '1.000.000'),
      (-1500, '-1.500'),
    ]) {
      test('Cenário: Dado o inteiro $valor, então vejo "$texto"', () {
        expect(formatarInteiro(valor), texto);
      });
    }

    for (final (valor, texto) in [
      (46.7, '46,7'),
      (46.75, '46,8'),
      (0.04, '0,0'),
      (1234.5, '1.234,5'),
      (3.0, '3,0'),
    ]) {
      test('Cenário: Dado o decimal $valor, então vejo "$texto"', () {
        expect(formatarDecimal(valor), texto);
      });
    }

    test('Cenário: Dado 0 casas, então não há vírgula', () {
      expect(formatarDecimal(1234.4, casas: 0), '1.234');
    });
  });
}
