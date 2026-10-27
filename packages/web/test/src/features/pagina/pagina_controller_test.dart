import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _desativado = FalhaApi(
  codigo: 'LOJISTA_DESATIVADO',
  mensagem: 'Sua conta está desativada.',
);

const _invalida = FalhaApi(
  codigo: 'ESTRUTURA_INVALIDA',
  mensagem: 'A ordem enviada não corresponde às categorias e produtos desta filial. Recarregue e tente de novo.',
);

List<String> _ids(List<CategoriaEstruturaResponse> categorias) => [
  for (final c in categorias) c.nome,
];

/// 3 categorias: Hortifrúti, Mercearia e Bebidas (vazia).
final _tres = EstruturaResponse(
  categorias: [
    ...estruturaFake.categorias,
    const CategoriaEstruturaResponse(
      id: 'c-bebidas',
      nome: 'Bebidas',
      produtos: [],
    ),
  ],
);

/// Estrutura que só responde quando o teste manda.
final class _EstruturaControlada implements EstruturaRepository {
  final pedidos = <String, Completer<Either<Falha, EstruturaResponse>>>{};

  @override
  Future<Either<Falha, EstruturaResponse>> obter(String filialId) =>
      (pedidos[filialId] = Completer()).future;

  @override
  Future<Either<Falha, EstruturaResponse>> salvar(
    String filialId,
    EstruturaRequest request,
  ) => throw UnimplementedError();
}

void main() {
  group('Funcionalidade: Ordem da página em edição (RN45, D10)', () {
    late EstruturaRepositoryFake estrutura;
    late PaginaController controller;

    setUp(() async {
      estrutura = EstruturaRepositoryFake(estrutura: _tres);
      controller = paginaControllerDeTeste(estrutura: estrutura);
      await controller.carregar('f1');
    });

    test('Cenário: Dado carregado, quando moverCategoria(0, 2), então emEdicao muda, salvo não, e temMudancas é true', () {
      controller.moverCategoria(0, 2);

      expect(_ids(controller.emEdicao), ['Mercearia', 'Bebidas', 'Hortifrúti']);
      expect(_ids(controller.salvo), ['Hortifrúti', 'Mercearia', 'Bebidas']);
      expect(controller.temMudancas, isTrue);
    });

    test('Cenário: Dado o índice do onReorderItem, quando moverCategoria(0, 2) com 3 itens, então a 1ª vai para o fim; e moverCategoria(2, 0) a traz de volta', () {
      controller.moverCategoria(0, 2);
      expect(_ids(controller.emEdicao).last, 'Hortifrúti');

      controller.moverCategoria(2, 0);
      expect(_ids(controller.emEdicao), _ids(controller.salvo));
      expect(controller.temMudancas, isFalse);
    });

    test('Cenário: Dado mudanças, quando descartar, então emEdicao volta a salvo e temMudancas é false', () {
      controller
        ..moverProduto(estruturaFake.categorias.first.id, 0, 1)
        ..descartar();

      expect(controller.emEdicao, controller.salvo);
      expect(controller.temMudancas, isFalse);
    });

    test('Cenário: Dado mudanças, quando publicar com sucesso, então salvo e emEdicao são a resposta do PUT', () async {
      controller.moverCategoria(1, 0);

      final resultado = await controller.publicar();

      expect(resultado.isSuccess, isTrue);
      expect(_ids(controller.salvo), ['Mercearia', 'Hortifrúti', 'Bebidas']);
      expect(controller.emEdicao, controller.salvo);
      expect(controller.temMudancas, isFalse);
      expect(controller.publicando, isFalse);
      expect(
        (controller.estado as PaginaCarregada).dados.estrutura.categorias,
        controller.salvo,
      );
    });

    test('Cenário: Dado publicar, quando o PUT envia, então o corpo segue a ordem em edição', () async {
      final hortifruti = estruturaFake.categorias.first;
      controller
        ..moverCategoria(2, 0)
        ..direita(hortifruti.id, 0);

      await controller.publicar();

      expect(
        estrutura.pedidos.single,
        EstruturaRequest([
          const CategoriaOrdenada(id: 'c-bebidas', produtos: []),
          CategoriaOrdenada(
            id: hortifruti.id,
            produtos: [
              produtoEstruturaFakeMaca.id,
              produtoEstruturaFakeBanana.id,
            ],
          ),
          CategoriaOrdenada(
            id: estruturaFake.categorias.last.id,
            produtos: [produtoEstruturaFakeArroz.id],
          ),
        ]),
      );
    });

    test('Cenário: Dado 403 LOJISTA_DESATIVADO, quando publicar, então bloqueado é true e emEdicao é mantida', () async {
      estrutura.falhaAoSalvar = _desativado;
      controller.moverCategoria(0, 1);
      final emEdicao = controller.emEdicao;

      final resultado = await controller.publicar();

      expect(resultado, const Failure<Falha, Nada>(_desativado));
      expect(controller.bloqueado, isTrue);
      expect(controller.emEdicao, emEdicao);
      controller.moverCategoria(0, 1);
      expect(controller.emEdicao, emEdicao, reason: 'bloqueado não reordena');
    });

    test('Cenário: Dado 422 ESTRUTURA_INVALIDA, quando publicar, então recarrega e devolve a falha', () async {
      estrutura.falhaAoSalvar = _invalida;
      controller.moverCategoria(0, 1);

      final resultado = await controller.publicar();

      expect(resultado, const Failure<Falha, Nada>(_invalida));
      expect(estrutura.obtidas, ['f1', 'f1']);
      expect(controller.temMudancas, isFalse);
      expect(controller.estado, isA<PaginaCarregada>());
    });

    test('Cenário: Dado subir no índice 0 ou descer no último, quando aciono, então nada muda', () {
      var avisos = 0;
      controller
        ..addListener(() => avisos++)
        ..subir(0)
        ..descer(2)
        ..esquerda(estruturaFake.categorias.first.id, 0);

      expect(controller.temMudancas, isFalse);
      expect(avisos, 0);
    });

    test('Cenário: Dado as ações de acessibilidade, quando desço a 1ª e movo um produto à direita, então a ordem muda', () {
      final hortifruti = estruturaFake.categorias.first;
      controller
        ..descer(0)
        ..direita(hortifruti.id, 0);

      expect(_ids(controller.emEdicao), ['Mercearia', 'Hortifrúti', 'Bebidas']);
      expect(controller.emEdicao[1].produtos.map((p) => p.nome), [
        'Maçã gala',
        'Banana prata',
      ]);
    });

    test('Cenário: Dado carregar(A) e depois carregar(B), quando A responde por último, então o estado é de B', () async {
      final controlada = _EstruturaControlada();
      final outro = paginaControllerDeTeste(estrutura: controlada);

      final a = outro.carregar('A');
      final b = outro.carregar('B');
      await Future<void>.delayed(Duration.zero);
      controlada.pedidos['B']!.complete(Success(estruturaFake));
      await b;
      controlada.pedidos['A']!.complete(Success(_tres));
      await a;

      expect(outro.filialId, 'B');
      expect(_ids(outro.salvo), ['Hortifrúti', 'Mercearia']);
    });

    test('Cenário: Dado identidade com sePanfleto e panfleto vigente, quando carrego, então dados.exibePanfleto é true', () async {
      final outro = paginaControllerDeTeste(
        identidade: IdentidadeRepositoryFake(
          identidade: const IdentidadeResponse(
            nomeFantasia: 'Mercado Bom Preço',
            sePanfleto: true,
          ),
        ),
        panfletos: PanfletoRepositoryFake(
          panfletos: [panfletoFakeAgendado, panfletoFake],
        ),
      );

      await outro.carregar('f1');

      final dados = (outro.estado as PaginaCarregada).dados;
      expect(dados.panfletoVigente, panfletoFake);
      expect(dados.exibePanfleto, isTrue);
    });
  });
}
