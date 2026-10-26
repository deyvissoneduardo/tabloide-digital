import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

Map<String, Object?> corpoCategoria({
  String id = '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
  String nome = 'Mercearia',
}) => {
  'id': id,
  'nome': nome,
  'produtos': {'vigentes': 12, 'agendados': 3, 'vencidos': 7},
  'podeExcluir': false,
  'criadoEm': '2026-10-18T13:02:11.000Z',
  'atualizadoEm': '2026-10-18T13:02:11.000Z',
};

void main() {
  group('Funcionalidade: ler e enviar categoria', () {
    test('Cenário: Dado o corpo 200 da API, quando leio, então todos os campos viram tipos do Dart', () {
      expect(CategoriaResponse.fromJson(corpoCategoria()), categoriaFake);
      expect(categoriaFake.produtos.ativos, 15);
    });

    test('Cenário: Dado um corpo sem a contagem de produtos, quando leio, então lança FormatException', () {
      expect(
        () => CategoriaResponse.fromJson(
          {...corpoCategoria()}..remove('produtos'),
        ),
        throwsFormatException,
      );
      expect(
        () => CategoriaResponse.fromJson({
          ...corpoCategoria(),
          'produtos': {'vigentes': 1},
        }),
        throwsFormatException,
      );
    });

    test('Cenário: Dado um nome com espaços nas pontas, quando converto, então envio o nome aparado', () {
      expect(const CategoriaRequest(nome: '  Mercearia ').toJson(), {
        'nome': 'Mercearia',
      });
    });
  });
}
