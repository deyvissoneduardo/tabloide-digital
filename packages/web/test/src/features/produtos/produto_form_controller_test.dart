import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

class _ProdutoRepositoryMock extends Mock implements ProdutoRepository {}

const _filial = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

final _bytes = Uint8List.fromList([1, 2, 3]);

const _pedido = ProdutoRequest(
  nome: 'Feijão',
  categoriaId: 'c1',
  precoPromocionalCentavos: 899,
);

ProdutoRequest _mesmoConteudo({int promocional = 2199}) => ProdutoRequest(
  nome: produtoFake.nome,
  categoriaId: produtoFake.categoria.id,
  precoPromocionalCentavos: promocional,
  precoOriginalCentavos: produtoFake.precoOriginalCentavos,
  quantidade: produtoFake.quantidade,
  observacao: produtoFake.observacao,
  dataInicio: produtoFake.vigencia.dataInicio,
  dataLimite: produtoFake.vigencia.dataLimite,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_pedido);
    registerFallbackValue(EditarProdutoRequest.entre(produtoFake, _pedido));
    registerFallbackValue((bytes: <int>[], nome: ''));
  });

  group('Funcionalidade: formulário de produto na web', () {
    late ProdutoRepositoryFake repository;
    late ProdutoFormController controller;

    setUp(() {
      repository = ProdutoRepositoryFake(produtos: [produtoFake]);
      controller = produtoFormControllerDeTeste(repository: repository);
    });

    test('Cenário: Dado uma foto acima de 10 MB, quando escolho, então recuso no campo antes do envio (RNF05)', () {
      controller.escolherFoto(Uint8List(maxBytesFoto + 1), 'grande.jpg');

      expect(controller.foto, isNull);
      expect(
        controller.erroDoCampo('foto'),
        'A foto passa de 10 MB. Escolha uma menor.',
      );

      controller.escolherFoto(_bytes, 'ok.jpg');

      expect(controller.foto?.nome, 'ok.jpg');
      expect(controller.erroDoCampo('foto'), isNull);
    });

    test('Cenário: Dado um produto novo sem foto, quando publico, então crio sem foto e concluo', () async {
      await controller.salvar(filialId: _filial, request: _pedido);

      expect(controller.estado, isA<ProdutoFormConcluido>());
      expect(repository.pedidos, [_pedido]);
      expect(repository.fotosEnviadas, isEmpty);
    });

    test('Cenário: Dado um produto novo com foto, quando publico, então envio a foto junto', () async {
      controller.escolherFoto(_bytes, 'feijao.jpg');

      await controller.salvar(filialId: _filial, request: _pedido);

      expect(repository.fotosEnviadas, ['feijao.jpg']);
      expect(
        (controller.estado as ProdutoFormConcluido).produto.urlFoto,
        'https://midia.fake/produto/feijao.jpg',
      );
    });

    test('Cenário: Dado preço original menor (422), quando publico, então o erro vai para o campo Preço original (RN21)', () async {
      repository.falhaSimulada = const FalhaApi(
        codigo: 'PRECO_ORIGINAL_INVALIDO',
        mensagem: 'O preço original precisa ser maior que o preço promocional.',
      );

      await controller.salvar(filialId: _filial, request: _pedido);

      expect(
        controller.erroDoCampo('precoOriginalCentavos'),
        'O preço original precisa ser maior que o preço promocional.',
      );
      expect(controller.temErroNosCampos, isTrue);

      controller.limparErroDoCampo('precoOriginalCentavos');

      expect(controller.temErroNosCampos, isFalse);
    });

    test('Cenário: Dado limite do plano (409), quando publico, então a falha não vai para campo', () async {
      repository.falhaSimulada = const FalhaApi(
        codigo: 'LIMITE_DO_PLANO_ATINGIDO',
        mensagem: 'O limite do seu plano foi atingido.',
      );

      await controller.salvar(filialId: _filial, request: _pedido);

      expect(controller.temErroNosCampos, isFalse);
      expect(controller.estado, isA<ProdutoFormComFalha>());
    });

    test('Cenário: Dado nada alterado, quando salvo a edição, então não chamo a API e concluo com o mesmo produto', () async {
      await controller.salvar(
        filialId: _filial,
        request: _mesmoConteudo(),
        produto: produtoFake,
      );

      expect(repository.edicoes, isEmpty);
      expect(
        controller.estado,
        isA<ProdutoFormConcluido>().having(
          (e) => e.produto,
          'produto',
          produtoFake,
        ),
      );
    });

    test('Cenário: Dado só o preço alterado, quando salvo a edição, então envio só o preço (PATCH parcial)', () async {
      await controller.salvar(
        filialId: _filial,
        request: _mesmoConteudo(promocional: 1999),
        produto: produtoFake,
      );

      expect(repository.edicoes.single.toJson(), {
        'precoPromocionalCentavos': 1999,
      });
      expect(
        (controller.estado as ProdutoFormConcluido)
            .produto
            .precoPromocionalCentavos,
        1999,
      );
    });

    test('Cenário: Dado a foto removida, quando salvo a edição, então chamo DELETE da foto', () async {
      controller.removerFoto();

      await controller.salvar(
        filialId: _filial,
        request: _mesmoConteudo(),
        produto: produtoFake,
      );

      expect(repository.fotosRemovidas, [produtoFake.id]);
      expect(
        (controller.estado as ProdutoFormConcluido).produto.urlFoto,
        isNull,
      );
    });

    test('Cenário: Dado uma foto escolhida depois de remover, quando salvo, então troco a foto em vez de remover', () async {
      controller
        ..removerFoto()
        ..escolherFoto(_bytes, 'nova.jpg');

      await controller.salvar(
        filialId: _filial,
        request: _mesmoConteudo(),
        produto: produtoFake,
      );

      expect(controller.fotoRemovida, isFalse);
      expect(repository.fotosEnviadas, ['nova.jpg']);
      expect(repository.fotosRemovidas, isEmpty);
    });

    test('Cenário: Dado o preço salvo e a troca de foto falhando, quando salvo, então a falha traz o produto já atualizado', () async {
      final mock = _ProdutoRepositoryMock();
      final atualizado = ProdutoResponse(
        id: produtoFake.id,
        filialId: produtoFake.filialId,
        categoria: produtoFake.categoria,
        nome: produtoFake.nome,
        precoPromocionalCentavos: 1999,
        vigencia: produtoFake.vigencia,
        criadoEm: produtoFake.criadoEm,
        atualizadoEm: produtoFake.atualizadoEm,
      );
      when(() => mock.editar(any(), any(), any()))
          .thenAnswer((_) async => Success(atualizado));
      when(() => mock.trocarFoto(any(), any(), any())).thenAnswer(
        (_) async => const Failure(
          FalhaApi(codigo: 'IMAGEM_INVALIDA', mensagem: 'Imagem inválida.'),
        ),
      );
      controller = produtoFormControllerDeTeste(repository: mock)
        ..escolherFoto(_bytes, 'ruim.gif');

      await controller.salvar(
        filialId: _filial,
        request: _mesmoConteudo(promocional: 1999),
        produto: produtoFake,
      );

      expect(
        controller.estado,
        isA<ProdutoFormComFalha>().having(
          (e) => e.atualizado,
          'atualizado',
          atualizado,
        ),
      );
      expect(controller.erroDoCampo('foto'), 'Imagem inválida.');
    });

    test('Cenário: Dado o formulário fechado, quando reinicio, então limpo foto, erros e estado', () async {
      controller
        ..escolherFoto(Uint8List(maxBytesFoto + 1), 'grande.jpg')
        ..removerFoto()
        ..reiniciar();

      expect(controller.estado, isA<ProdutoFormOcioso>());
      expect(controller.foto, isNull);
      expect(controller.fotoRemovida, isFalse);
      expect(controller.temErroNosCampos, isFalse);
    });
  });
}
