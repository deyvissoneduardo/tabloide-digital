import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_front/main.dart';

void main() {
  group('Funcionalidade: escolha da marca no build', () {
    test('Cenário: Dado MARCA=mercado_exemplo, quando resolvo, então recebo o Mercado Exemplo', () {
      expect(resolverMarca('mercado_exemplo').nome, 'Mercado Exemplo');
    });

    test('Cenário: Dado o build sem MARCA, quando resolvo a padrão, então recebo o Tabloide Digital', () {
      expect(resolverMarca('tabloide').nome, 'Tabloide Digital');
    });

    test('Cenário: Dado MARCA inexistente, quando resolvo, então o app não sobe e o erro lista as disponíveis', () {
      expect(
        () => resolverMarca('padaria'),
        throwsA(
          isA<MarcaNaoRegistrada>().having(
            (e) => e.disponiveis,
            'disponiveis',
            containsAll(['tabloide', 'mercado_exemplo']),
          ),
        ),
      );
    });
  });
}
