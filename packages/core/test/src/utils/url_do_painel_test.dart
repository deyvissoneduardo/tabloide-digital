import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: abrir a página pública pelo painel sem contar acesso', () {
    test('Cenário: Dado a URL pública, quando o lojista abre pelo painel, então ganho ?origem=painel', () {
      expect(
        urlAbertaPeloPainel('https://tabloide.digital/c/centro-abc'),
        'https://tabloide.digital/c/centro-abc?origem=painel',
      );
    });

    test('Cenário: Dado uma URL que já tem parâmetros, então mantenho os parâmetros e acrescento a origem', () {
      expect(
        urlAbertaPeloPainel('https://tabloide.digital/c/centro?x=1'),
        'https://tabloide.digital/c/centro?x=1&origem=painel',
      );
    });
  });
}
