import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
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
  _mainAparencia();
}

final _imagem = ImagemPendente(
  bytes: Uint8List.fromList([1, 2, 3]),
  nomeArquivo: 'banner.png',
);

void _mainAparencia() {
  group('Funcionalidade: Publicar aparência + ordem (T7, RN46–RN48)', () {
    late EstruturaRepositoryFake estrutura;
    late ConfiguracaoPaginaRepositoryFake configuracao;
    late PaginaController controller;

    setUp(() async {
      estrutura = EstruturaRepositoryFake(estrutura: _tres);
      configuracao = ConfiguracaoPaginaRepositoryFake();
      controller = paginaControllerDeTeste(
        estrutura: estrutura,
        configuracao: configuracao,
      );
      await controller.carregar('f1');
    });

    test('Cenário: Dado carregado, então a aparência em edição é a salva e não há mudanças', () {
      expect(controller.aparenciaSalva, ConfiguracaoPaginaResponse.padrao);
      expect(
        controller.aparenciaEmEdicao.configuracao,
        ConfiguracaoPaginaResponse.padrao,
      );
      expect(controller.temMudancas, isFalse);
    });

    test(
      'Cenário: Dado uma cor editada, então temMudancas é true sem salvar nada',
      () {
        controller.editarAparencia((e) => e.comCor(CorPagina.texto, '#112233'));

        expect(controller.aparenciaMudou, isTrue);
        expect(controller.ordemMudou, isFalse);
        expect(controller.temMudancas, isTrue);
        expect(configuracao.chamadas, isEmpty);
      },
    );

    test('Cenário: Dado só a aparência mudou, quando publico, então só o PATCH sai e tudo vira salvo', () async {
      controller.editarAparencia(
        (e) =>
            e.comExibirBanner(true).comNomeBanner('  Semana   do Hortifrúti '),
      );

      final resultado = await controller.publicar();

      expect(resultado.isSuccess, isTrue);
      expect(configuracao.chamadas, ['PATCH']);
      expect(configuracao.pedidos.single.toJson(), {
        'banner': {'exibir': true, 'nome': 'Semana do Hortifrúti'},
      });
      expect(estrutura.pedidos, isEmpty);
      expect(controller.temMudancas, isFalse);
      expect(controller.aparenciaSalva.banner.exibir, isTrue);
      expect(
        (controller.estado as PaginaCarregada).dados.configuracao,
        controller.aparenciaSalva,
      );
    });

    test(
      'Cenário: Dado só a ordem mudou, quando publico, então só o PUT sai',
      () async {
        controller.moverCategoria(0, 1);

        await controller.publicar();

        expect(configuracao.chamadas, isEmpty);
        expect(estrutura.pedidos, hasLength(1));
        expect(controller.temMudancas, isFalse);
      },
    );

    test('Cenário: Dado aparência e ordem com falha no PUT, quando publico, então a aparência fica salva e a ordem pendente (E12)', () async {
      estrutura.falhaAoSalvar = const FalhaSemConexao();
      controller
        ..editarAparencia((e) => e.comExibirNomeCategoria(false))
        ..moverCategoria(0, 1);

      final resultado = await controller.publicar();

      expect(resultado, const Failure<Falha, Nada>(FalhaSemConexao()));
      expect(configuracao.chamadas, ['PATCH']);
      expect(controller.aparenciaMudou, isFalse);
      expect(controller.aparenciaSalva.exibirNomeCategoria, isFalse);
      expect(controller.ordemMudou, isTrue);
      expect(controller.temMudancas, isTrue);
    });

    test('Cenário: Dado logo, foto e cor pendentes, quando publico, então uploads antes do PATCH e as URLs novas viram salvas', () async {
      controller.editarAparencia(
        (e) => e
            .comExibirBanner(true)
            .comLogo(_imagem)
            .comFoto(_imagem)
            .comCor(CorPagina.fundoBanner, '#0B3D91'),
      );

      await controller.publicar();

      expect(configuracao.chamadas, ['PUT logo', 'PUT foto', 'PATCH']);
      expect(
        controller.aparenciaSalva.banner.urlLogo,
        'https://midia.fake/logo/banner.png',
      );
      expect(
        controller.aparenciaSalva.banner.campanha,
        const CampanhaFoto('https://midia.fake/banner/banner.png'),
      );
      expect(controller.aparenciaEmEdicao.logo, isNull);
      expect(controller.aparenciaEmEdicao.foto, isNull);
      expect(controller.temMudancas, isFalse);
    });

    test('Cenário: Dado falha no upload do logo, quando publico, então nada mais é enviado e tudo continua pendente', () async {
      configuracao.falhaAoEnviar = const FalhaSemConexao();
      controller
        ..editarAparencia(
          (e) => e.comLogo(_imagem).comCor(CorPagina.texto, '#112233'),
        )
        ..moverCategoria(0, 1);

      final resultado = await controller.publicar();

      expect(resultado.isFailure, isTrue);
      expect(configuracao.chamadas, ['PUT logo']);
      expect(estrutura.pedidos, isEmpty);
      expect(controller.aparenciaEmEdicao.logo, isNotNull);
      expect(controller.aparenciaMudou, isTrue);
      expect(controller.ordemMudou, isTrue);
    });

    test('Cenário: Dado foto salva e campanha trocada para Nenhuma, quando publico, então DELETE da foto', () async {
      configuracao.configuracao = configuracaoPaginaFake;
      await controller.carregar('f1');
      controller.editarAparencia(
        (e) => e.comTipoCampanha(TipoCampanha.nenhuma),
      );

      await controller.publicar();

      expect(configuracao.chamadas, ['DELETE foto']);
      expect(controller.aparenciaSalva.banner.campanha, isNull);
      expect(controller.temMudancas, isFalse);
    });

    test('Cenário: Dado logo salvo e removido, quando publico, então DELETE do logo', () async {
      configuracao.configuracao = configuracaoPaginaFake;
      await controller.carregar('f1');
      controller.editarAparencia((e) => e.semLogo());

      await controller.publicar();

      expect(configuracao.chamadas, ['DELETE logo']);
      expect(controller.aparenciaSalva.banner.urlLogo, isNull);
    });

    test('Cenário: Dado foto salva e campanha trocada para descrição, quando publico, então só o PATCH com a descrição', () async {
      configuracao.configuracao = configuracaoPaginaFake;
      await controller.carregar('f1');
      controller.editarAparencia(
        (e) => e
            .comTipoCampanha(TipoCampanha.descricao)
            .comDescricao('Tudo fresquinho'),
      );

      await controller.publicar();

      expect(configuracao.chamadas, ['PATCH']);
      expect(
        controller.aparenciaSalva.banner.campanha,
        const CampanhaDescricao('Tudo fresquinho'),
      );
    });

    test('Cenário: Dado 403 no PATCH, quando publico, então bloqueado e a aparência não muda mais', () async {
      configuracao.falhaAoEditar = _desativado;
      controller.editarAparencia((e) => e.comExibirNomeCategoria(false));

      await controller.publicar();
      controller.editarAparencia((e) => e.comExibirNomeCategoria(true));

      expect(controller.bloqueado, isTrue);
      expect(controller.aparenciaEmEdicao.exibirNomeCategoria, isFalse);
    });

    test('Cenário: Dado ordem e aparência alteradas, quando descarto, então as duas voltam ao salvo e a revisão muda', () {
      final revisao = controller.revisaoAparencia;
      controller
        ..editarAparencia((e) => e.comExibirBanner(true).comLogo(_imagem))
        ..moverCategoria(0, 1)
        ..descartar();

      expect(controller.temMudancas, isFalse);
      expect(controller.aparenciaEmEdicao.logo, isNull);
      expect(controller.revisaoAparencia, revisao + 1);
    });
  });

  group('Funcionalidade: Editar produto pelo editor (U17, T9)', () {
    late PaginaController controller;

    setUp(() async {
      controller = paginaControllerDeTeste(
        estrutura: EstruturaRepositoryFake(estrutura: _tres),
      );
      await controller.carregar('f1');
    });

    ProdutoResponse editado({
      required String id,
      required String nome,
      required String categoriaId,
      int preco = 199,
    }) => ProdutoResponse(
      id: id,
      filialId: 'f1',
      categoria: CategoriaDoProduto(id: categoriaId, nome: 'x'),
      nome: nome,
      precoPromocionalCentavos: preco,
      vigencia: produtoEstruturaFakeBanana.vigencia,
      criadoEm: DateTime(2026),
      atualizadoEm: DateTime(2026),
    );

    test('Cenário: Dado a ordem pendente, quando o produto é salvo, então nome e preço mudam no lugar e a ordem continua pendente (E10)', () {
      final hortifruti = estruturaFake.categorias.first;
      controller.direita(hortifruti.id, 0);

      controller.produtoEditado(
        editado(
          id: produtoEstruturaFakeBanana.id,
          nome: 'Banana nanica',
          categoriaId: hortifruti.id,
        ),
      );

      expect(controller.emEdicao.first.produtos.map((p) => p.nome), [
        'Maçã gala',
        'Banana nanica',
      ]);
      expect(controller.salvo.first.produtos.map((p) => p.nome), [
        'Banana nanica',
        'Maçã gala',
      ]);
      expect(
        controller.emEdicao.first.produtos.last.precoPromocionalCentavos,
        199,
      );
      expect(controller.temMudancas, isTrue);
    });

    test('Cenário: Dado sem mudanças, quando o produto é salvo, então temMudancas continua false', () {
      controller.produtoEditado(
        editado(
          id: produtoEstruturaFakeArroz.id,
          nome: 'Arroz 1 kg',
          categoriaId: estruturaFake.categorias.last.id,
        ),
      );

      expect(controller.temMudancas, isFalse);
      expect(controller.emEdicao[1].produtos.single.nome, 'Arroz 1 kg');
    });

    test('Cenário: Dado troca de categoria, quando o produto é salvo, então ele vai para o fim da nova categoria nas duas listas (E11)', () {
      final mercearia = estruturaFake.categorias.last;

      controller.produtoEditado(
        editado(
          id: produtoEstruturaFakeBanana.id,
          nome: 'Banana prata',
          categoriaId: mercearia.id,
        ),
      );

      for (final lista in [controller.emEdicao, controller.salvo]) {
        expect(lista.first.produtos.map((p) => p.nome), ['Maçã gala']);
        expect(lista[1].produtos.map((p) => p.nome), [
          'Arroz 5 kg',
          'Banana prata',
        ]);
      }
      expect(controller.temMudancas, isFalse);
    });
  });
}
