import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

/// JSON do plano §4.2 (com categoria sem produtos e produto sem opcionais).
Map<String, Object?> corpoEstrutura() => {
  'categorias': [
    {
      'id': '0192a0b0-2222-7000-8000-000000000001',
      'nome': 'Hortifrúti',
      'produtos': [
        {
          'id': produtoEstruturaFakeBanana.id,
          'nome': 'Banana prata',
          'quantidade': 'kg',
          'descricao': null,
          'observacao': null,
          'precoPromocionalCentavos': 499,
          'precoOriginalCentavos': 699,
          'urlFoto': null,
          'dataInicio': '2026-10-20',
          'dataLimite': '2026-11-20',
          'situacao': 'VIGENTE',
          'editavel': true,
        },
        {
          'id': produtoEstruturaFakeMaca.id,
          'nome': 'Maçã gala',
          'quantidade': 'kg',
          'descricao': null,
          'observacao': 'Limite 3 por cliente',
          'precoPromocionalCentavos': 899,
          'precoOriginalCentavos': null,
          'urlFoto': null,
          'dataInicio': '2026-11-01',
          'dataLimite': null,
          'situacao': 'AGENDADO',
          'editavel': true,
        },
      ],
    },
    {
      'id': '0192a0b0-2222-7000-8000-000000000002',
      'nome': 'Mercearia',
      'produtos': [
        {
          'id': produtoEstruturaFakeArroz.id,
          'nome': 'Arroz 5 kg',
          'quantidade': null,
          'descricao': 'Tipo 1',
          'observacao': null,
          'precoPromocionalCentavos': 2490,
          'precoOriginalCentavos': null,
          'urlFoto': null,
          'dataInicio': '2026-10-20',
          'dataLimite': null,
          'situacao': 'VIGENTE',
          'editavel': true,
        },
      ],
    },
    {
      'id': '0192a0b0-2222-7000-8000-000000000003',
      'nome': 'Bebidas',
      'produtos': [],
    },
  ],
};

void main() {
  group('Funcionalidade: Estrutura da filial', () {
    test('Cenário: Dado o JSON do plano §4.2 com categoria sem produtos e produto sem opcionais, quando leio, então vira a estrutura em ordem', () {
      final estrutura = EstruturaResponse.fromJson(corpoEstrutura());

      expect(
        estrutura,
        EstruturaResponse(
          categorias: [
            ...estruturaFake.categorias,
            const CategoriaEstruturaResponse(
              id: '0192a0b0-2222-7000-8000-000000000003',
              nome: 'Bebidas',
              produtos: [],
            ),
          ],
        ),
      );
      expect(
        estrutura.categorias.first.produtos.last.vigencia.situacao,
        SituacaoVigencia.agendado,
      );
    });

    test('Cenário: Dado um JSON fora do formato, quando leio, então lança FormatException', () {
      expect(
        () => EstruturaResponse.fromJson({'itens': []}),
        throwsFormatException,
      );
      expect(
        () => EstruturaResponse.fromJson({
          'categorias': [
            {'id': 'c', 'nome': 'X'},
          ],
        }),
        throwsFormatException,
      );
      expect(
        () => EstruturaResponse.fromJson({
          'categorias': [
            {
              'id': 'c',
              'nome': 'X',
              'produtos': [
                {'id': 'p', 'nome': 'Y'},
              ],
            },
          ],
        }),
        throwsFormatException,
      );
    });

    test('Cenário: Dado uma categoria, quando troco os produtos com comProdutos, então id e nome se mantêm', () {
      final categoria = estruturaFake.categorias.first;

      final nova = categoria.comProdutos([produtoEstruturaFakeMaca]);

      expect(nova.id, categoria.id);
      expect(nova.nome, categoria.nome);
      expect(nova.produtos, [produtoEstruturaFakeMaca]);
    });
  });
}
