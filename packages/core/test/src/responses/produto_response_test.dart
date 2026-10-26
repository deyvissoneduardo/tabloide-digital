import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

Map<String, Object?> corpoProduto({
  String id = '0192f0d0-a062-7f54-9b7e-5a6b7c8d9e05',
  String situacao = 'VIGENTE',
  String? urlFoto =
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/produto/0192f0d1.webp',
}) => {
  'id': id,
  'filialId': '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  'categoria': {
    'id': '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
    'nome': 'Mercearia',
  },
  'nome': 'Arroz Tipo 1',
  'quantidade': '5kg',
  'precoPromocionalCentavos': 2199,
  'precoOriginalCentavos': 2649,
  'descricao': null,
  'observacao': 'Limite 3 por cliente',
  'urlFoto': urlFoto,
  'dataInicio': '2026-10-18',
  'dataLimite': '2026-10-25',
  'situacao': situacao,
  'editavel': true,
  'dataInicioEditavel': false,
  'criadoEm': '2026-10-18T15:10:00.000Z',
  'atualizadoEm': '2026-10-18T15:10:00.000Z',
  'excluidoEm': null,
};

ProdutoRequest _pedido({
  String nome = 'Arroz Tipo 1',
  String categoriaId = '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
  int promocional = 2199,
  int? original = 2649,
  String? quantidade = '5kg',
  String? descricao,
  String? observacao = 'Limite 3 por cliente',
  DateTime? inicio,
  DateTime? limite,
}) => ProdutoRequest(
  nome: nome,
  categoriaId: categoriaId,
  precoPromocionalCentavos: promocional,
  precoOriginalCentavos: original,
  quantidade: quantidade,
  descricao: descricao,
  observacao: observacao,
  dataInicio: inicio ?? DateTime(2026, 10, 18),
  dataLimite: limite ?? DateTime(2026, 10, 25),
);

void main() {
  group('Funcionalidade: ler produto', () {
    test('Cenário: Dado o corpo 200 da API, quando leio, então todos os campos viram tipos do Dart', () {
      expect(ProdutoResponse.fromJson(corpoProduto()), produtoFake);
    });

    test(
      'Cenário: Dado um produto sem foto, quando leio, então urlFoto fica nula',
      () {
        expect(
          ProdutoResponse.fromJson(corpoProduto(urlFoto: null)).urlFoto,
          isNull,
        );
      },
    );

    test('Cenário: Dado um corpo sem categoria, quando leio, então lança FormatException', () {
      expect(
        () =>
            ProdutoResponse.fromJson({...corpoProduto()}..remove('categoria')),
        throwsFormatException,
      );
    });

    test('Cenário: Dado uma situação fora de vigente e agendado, quando leio, então lança FormatException', () {
      expect(
        () => ProdutoResponse.fromJson(corpoProduto(situacao: 'VENCIDO')),
        throwsFormatException,
      );
    });
  });

  group('Funcionalidade: enviar produto novo', () {
    test('Cenário: Dado todos os campos, quando converto, então envio JSON com centavos inteiros e datas aaaa-mm-dd', () {
      expect(_pedido(descricao: 'Grão longo').toJson(), {
        'nome': 'Arroz Tipo 1',
        'categoriaId': '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
        'precoPromocionalCentavos': 2199,
        'precoOriginalCentavos': 2649,
        'quantidade': '5kg',
        'descricao': 'Grão longo',
        'observacao': 'Limite 3 por cliente',
        'dataInicio': '2026-10-18',
        'dataLimite': '2026-10-25',
      });
    });

    test('Cenário: Dado opcionais vazios ou só com espaços, quando converto, então omito os campos', () {
      const pedido = ProdutoRequest(
        nome: ' Arroz ',
        categoriaId: 'c1',
        precoPromocionalCentavos: 100,
        quantidade: '  ',
        observacao: '',
      );

      expect(pedido.toJson(), {
        'nome': 'Arroz',
        'categoriaId': 'c1',
        'precoPromocionalCentavos': 100,
      });
    });

    test('Cenário: Dado um pedido com foto, quando converto para multipart, então todo valor vira texto', () {
      expect(
        const ProdutoRequest(
          nome: 'Refrigerante cola',
          categoriaId: 'c1',
          precoPromocionalCentavos: 799,
          precoOriginalCentavos: 1099,
        ).toCampos(),
        {
          'nome': 'Refrigerante cola',
          'categoriaId': 'c1',
          'precoPromocionalCentavos': '799',
          'precoOriginalCentavos': '1099',
        },
      );
    });
  });

  group('Funcionalidade: editar produto só no que mudou', () {
    test('Cenário: Dado o mesmo conteúdo do produto, quando comparo, então o pedido fica vazio', () {
      expect(EditarProdutoRequest.entre(produtoFake, _pedido()).vazio, isTrue);
    });

    test('Cenário: Dado preço novo e observação apagada, quando comparo, então envio o preço e observacao nula', () {
      final pedido = EditarProdutoRequest.entre(
        produtoFake,
        _pedido(promocional: 1999, observacao: ''),
      );

      expect(pedido.toJson(), {
        'precoPromocionalCentavos': 1999,
        'observacao': null,
      });
    });

    test('Cenário: Dado um produto vigente, quando a data de início muda, então ela não é enviada (RN26)', () {
      final pedido = EditarProdutoRequest.entre(
        produtoFake,
        _pedido(inicio: DateTime(2026, 10, 20)),
      );

      expect(pedido.vazio, isTrue);
    });

    test('Cenário: Dado um produto agendado, quando a data de início muda, então ela é enviada', () {
      final pedido = EditarProdutoRequest.entre(
        produtoFakeAgendado,
        ProdutoRequest(
          nome: produtoFakeAgendado.nome,
          categoriaId: produtoFakeAgendado.categoria.id,
          precoPromocionalCentavos: 799,
          quantidade: '2 L',
          dataInicio: DateTime(2026, 11, 5),
        ),
      );

      expect(pedido.toJson(), {'dataInicio': '2026-11-05'});
    });

    test('Cenário: Dado a data limite e o preço original removidos, quando comparo, então envio os dois como nulos', () {
      final pedido = EditarProdutoRequest.entre(
        produtoFake,
        ProdutoRequest(
          nome: 'Arroz Tipo 1',
          categoriaId: produtoFake.categoria.id,
          precoPromocionalCentavos: 2199,
          quantidade: '5kg',
          observacao: 'Limite 3 por cliente',
          dataInicio: DateTime(2026, 10, 18),
        ),
      );

      expect(pedido.toJson(), {
        'precoOriginalCentavos': null,
        'dataLimite': null,
      });
    });
  });
}
