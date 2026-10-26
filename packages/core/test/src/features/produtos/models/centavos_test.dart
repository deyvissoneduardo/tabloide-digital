import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: preço em centavos', () {
    test('Cenário: Dado valores em centavos, quando formato, então mostro em reais no padrão pt-BR', () {
      expect(Centavos.formatar(5), r'R$ 0,05');
      expect(Centavos.formatar(2199), r'R$ 21,99');
      expect(Centavos.formatar(123456789), r'R$ 1.234.567,89');
    });

    test('Cenário: Dado o texto do campo de preço, quando leio, então fico só com os dígitos em centavos', () {
      expect(Centavos.ler(r'R$ 1.234,56'), 123456);
      expect(Centavos.ler('0,99'), 99);
      expect(Centavos.ler(''), isNull);
      expect(Centavos.ler(r'R$ '), isNull);
    });
  });
}
