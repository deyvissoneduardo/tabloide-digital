import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _desativado = FalhaApi(
  codigo: 'LOJISTA_DESATIVADO',
  mensagem: 'Sua conta está desativada.',
);

Finder get _publicar => find.widgetWithText(ElevatedButton, 'Publicar');

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

/// Produto completo da banana, na categoria Hortifrúti da estrutura fake.
final _banana = ProdutoResponse(
  id: produtoEstruturaFakeBanana.id,
  filialId: 'f1',
  categoria: CategoriaDoProduto(
    id: estruturaFake.categorias.first.id,
    nome: 'Hortifrúti',
  ),
  nome: 'Banana prata',
  quantidade: 'kg',
  precoPromocionalCentavos: 499,
  precoOriginalCentavos: 699,
  vigencia: produtoEstruturaFakeBanana.vigencia,
  criadoEm: DateTime.utc(2026, 10, 20),
  atualizadoEm: DateTime.utc(2026, 10, 20),
);

final _hortifruti = CategoriaResponse(
  id: estruturaFake.categorias.first.id,
  nome: 'Hortifrúti',
  produtos: const ContagemProdutos(vigentes: 1, agendados: 1, vencidos: 0),
  podeExcluir: false,
  criadoEm: DateTime.utc(2026, 10, 18),
  atualizadoEm: DateTime.utc(2026, 10, 18),
);

void main() {
  group('Funcionalidade: Seção Página', () {
    late EstruturaRepositoryFake estrutura;
    late ConfiguracaoPaginaRepositoryFake configuracao;
    late ProdutoRepositoryFake produtos;
    late HomeController home;
    late PaginaController pagina;

    setUp(() {
      estrutura = EstruturaRepositoryFake();
      configuracao = ConfiguracaoPaginaRepositoryFake();
      produtos = ProdutoRepositoryFake(produtos: [_banana]);
      pagina = paginaControllerDeTeste(
        estrutura: estrutura,
        configuracao: configuracao,
      );
      home = controllerDeTeste()..selecionar(SecaoPainel.pagina);
    });

    Future<FiliaisController> abrir(
      WidgetTester tester, {
      Size tamanho = const Size(400, 900),
      List<FilialResponse>? filiais,
      bool assentar = true,
    }) async {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = filiaisControllerDeTeste(
        repository: FilialRepositoryFake(filiais: filiais ?? [filialFake]),
      );
      await tester.runAsync(controller.carregar);
      controller.usar(controller.filiais.first);
      await tester.pumpWidget(
        montarTela(
          const HomeScreen(),
          home: home,
          filiais: controller,
          pagina: pagina,
          produtoRepository: produtos,
          categoriaRepository: CategoriaRepositoryFake(
            categorias: [_hortifruti],
          ),
        ),
      );
      if (assentar) await tester.pumpAndSettle();
      return controller;
    }

    testWidgets('Cenário: Dado carregando, quando abro, então EsqueletoLista', (
      tester,
    ) async {
      estrutura.atraso = const Duration(seconds: 1);
      await abrir(tester, assentar: false);
      await tester.pump();

      expect(find.byType(EsqueletoLista), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(EsqueletoLista), findsNothing);
    });

    testWidgets(
      'Cenário: Dado falha, quando abro, então EstadoFalha e "Tentar de novo" recarrega',
      (tester) async {
        estrutura.falha = const FalhaSemConexao();
        await abrir(tester);

        expect(find.byType(EstadoFalha), findsOneWidget);
        estrutura.falha = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.text('Hortifrúti'), findsOneWidget);
        expect(estrutura.obtidas, hasLength(2));
      },
    );

    testWidgets(
      'Cenário: Dado carregado, quando arrasto uma categoria, então a prévia mostra a nova ordem sem publicar',
      (tester) async {
        await abrir(tester);

        final alca = find
            .descendant(
              of: find.widgetWithText(AppEditorCategoria, 'Hortifrúti'),
              matching: find.byIcon(Icons.drag_indicator),
            )
            .first;
        final gesto = await tester.startGesture(tester.getCenter(alca));
        for (var i = 0; i < 10; i++) {
          await gesto.moveBy(const Offset(0, 40));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await gesto.up();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Prévia'));
        await tester.pumpAndSettle();

        final previa = find.byType(AppPreviaPagina);
        expect(
          tester
              .getTopLeft(
                find.descendant(of: previa, matching: find.text('Mercearia')),
              )
              .dy,
          lessThan(
            tester
                .getTopLeft(
                  find.descendant(
                    of: previa,
                    matching: find.text('Hortifrúti'),
                  ),
                )
                .dy,
          ),
        );
        expect(estrutura.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado sem mudanças, quando desenho, então "Publicar" está desabilitado',
      (tester) async {
        await abrir(tester);

        expect(tester.widget<ElevatedButton>(_publicar).onPressed, isNull);
      },
    );

    testWidgets(
      'Cenário: Dado mudanças, quando toco em "Publicar", então aparece o spinner no botão e depois o aviso de sucesso',
      (tester) async {
        await abrir(tester);
        pagina.moverCategoria(0, 1);
        await tester.pump();
        estrutura.atraso = const Duration(milliseconds: 500);

        await tester.tap(_publicar);
        await tester.pump();
        expect(
          find.descendant(
            of: find.byType(AppBotaoPrincipal),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(
          find.text('Página publicada. Ela atualiza em até 1 minuto.'),
          findsOneWidget,
        );
        expect(estrutura.pedidos, hasLength(1));
      },
    );

    testWidgets(
      'Cenário: Dado 403, quando publico, então aparece o aviso de conta desativada e as alças somem',
      (tester) async {
        estrutura.falhaAoSalvar = _desativado;
        await abrir(tester);
        expect(find.byIcon(Icons.drag_indicator), findsWidgets);
        pagina.moverCategoria(0, 1);
        await tester.pump();

        await tester.tap(_publicar);
        await tester.pumpAndSettle();

        expect(
          find.text('Conta desativada: a página não pode ser alterada.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.drag_indicator), findsNothing);
        expect(tester.widget<ElevatedButton>(_publicar).onPressed, isNull);
      },
    );

    testWidgets(
      'Cenário: Dado sem categorias, quando abro, então EstadoVazio com "Ir para Produtos"',
      (tester) async {
        estrutura.estrutura = const EstruturaResponse(categorias: []);
        await abrir(tester);

        expect(
          find.text('Crie categorias e produtos para montar a página'),
          findsOneWidget,
        );
        await tester.tap(find.text('Ir para Produtos'));
        await tester.pumpAndSettle();

        expect(home.secao, SecaoPainel.produtos);
      },
    );

    testWidgets(
      'Cenário: Dado troca da filial em uso, quando volto à seção, então carrega a estrutura da nova filial',
      (tester) async {
        final filiais = await abrir(
          tester,
          filiais: [filialFake, filialFakeBairro],
        );
        expect(estrutura.obtidas, [filialFake.id]);

        filiais.usar(filialFakeBairro);
        await tester.pumpAndSettle();

        expect(estrutura.obtidas, [filialFake.id, filialFakeBairro.id]);
      },
    );

    for (final (nome, tamanho) in [
      ('celular (400 px)', const Size(400, 900)),
      ('tablet (900 px)', const Size(900, 1000)),
    ]) {
      testWidgets(
        'Cenário: Dado $nome, quando abro, então há TabBar "Montar", "Aparência" e "Prévia" (D12, app sempre em abas)',
        (tester) async {
          await abrir(tester, tamanho: tamanho);

          expect(find.byType(TabBar), findsOneWidget);
          expect(find.text('Montar'), findsOneWidget);
          expect(find.text('Aparência'), findsOneWidget);
          expect(find.text('Prévia'), findsOneWidget);
        },
      );
    }

    Future<void> abrirAparencia(WidgetTester tester) async {
      await abrir(tester, tamanho: const Size(400, 3200));
      await tester.tap(find.text('Aparência'));
      await tester.pumpAndSettle();
    }

    Future<void> verPrevia(WidgetTester tester) async {
      await tester.tap(find.text('Prévia'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado a aba Aparência, quando ligo o banner, então os campos do banner aparecem e a prévia troca o cabeçalho',
      (tester) async {
        await abrirAparencia(tester);
        expect(find.text('Cor do banner'), findsNothing);

        await tester.tap(find.text('Mostrar banner'));
        await tester.pumpAndSettle();

        expect(find.text('Cor do banner'), findsOneWidget);
        expect(find.text('Logo do banner'), findsOneWidget);
        expect(_campo('Nome do banner'), findsOneWidget);
        expect(find.byType(AppCampoCampanha), findsOneWidget);
        expect(pagina.temMudancas, isTrue);
        expect(
          configuracao.chamadas,
          isEmpty,
          reason: 'nada salvo antes de Publicar',
        );
        await verPrevia(tester);
        expect(find.byType(AppPreviaBanner), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o banner ligado com nome, quando desligo, então os campos somem e o nome é mantido',
      (tester) async {
        await abrirAparencia(tester);
        await tester.tap(find.text('Mostrar banner'));
        await tester.pumpAndSettle();
        await tester.enterText(_campo('Nome do banner'), 'Semana');
        await tester.pump();

        await tester.tap(find.text('Mostrar banner'));
        await tester.pumpAndSettle();
        expect(_campo('Nome do banner'), findsNothing);
        await tester.tap(find.text('Mostrar banner'));
        await tester.pumpAndSettle();

        expect(find.text('Semana'), findsOneWidget);
        expect(pagina.aparenciaEmEdicao.nomeBanner, 'Semana');
      },
    );

    testWidgets(
      'Cenário: Dado a cor primária em edição, quando vejo a prévia, então o nome do produto usa a cor exata',
      (tester) async {
        await abrirAparencia(tester);
        final campo = _campo('Cor primária');
        await tester.ensureVisible(campo);
        await tester.enterText(campo, '#FFD100');
        await tester.pump();

        await verPrevia(tester);

        final cor = tester
            .widget<Text>(
              find.descendant(
                of: find.byType(AppPreviaPagina),
                matching: find.text('Banana prata'),
              ),
            )
            .style!
            .color!;
        expect(AppCoresPagina.paraHex(cor), '#FFD100');
      },
    );

    testWidgets(
      'Cenário: Dado uma cor incompleta, quando digito, então o erro aparece no campo e a edição não muda',
      (tester) async {
        await abrirAparencia(tester);
        final campo = _campo('Cor do texto');
        await tester.ensureVisible(campo);

        await tester.enterText(campo, '#12');
        await tester.pump();

        expect(find.text('Informe a cor no formato #RRGGBB.'), findsOneWidget);
        expect(pagina.aparenciaEmEdicao.cores.texto, isNull);
      },
    );

    testWidgets(
      'Cenário: Dado nome da categoria desligado, quando vejo a prévia, então a grade única aparece',
      (tester) async {
        await abrirAparencia(tester);
        final chave = find.text('Mostrar nome da categoria');
        await tester.ensureVisible(chave);
        await tester.tap(chave);
        await tester.pumpAndSettle();

        await verPrevia(tester);

        expect(find.byType(AppPreviaGradeProdutos), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado só a aparência alterada, quando publico, então o PATCH sai e o aviso de sucesso aparece',
      (tester) async {
        await abrirAparencia(tester);
        await tester.tap(find.text('Mostrar banner'));
        await tester.pumpAndSettle();

        await tester.tap(_publicar);
        await tester.pumpAndSettle();

        expect(configuracao.chamadas, ['PATCH']);
        expect(estrutura.pedidos, isEmpty);
        expect(
          find.text('Página publicada. Ela atualiza em até 1 minuto.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado a ordem pendente, quando toco num produto e salvo o formulário, então o produto muda no editor e a ordem continua pendente (E10)',
      (tester) async {
        await abrir(tester);
        pagina.moverCategoria(0, 1);
        await tester.pump();

        await tester.tap(find.text('Banana prata'));
        await tester.pumpAndSettle();
        expect(find.byType(ProdutoFormScreen), findsOneWidget);
        await tester.enterText(_campo('Nome do produto'), 'Banana nanica');
        final salvar = find.widgetWithText(ElevatedButton, 'Salvar produto');
        await tester.ensureVisible(salvar);
        await tester.tap(salvar);
        await tester.pumpAndSettle();

        expect(find.byType(ProdutoFormScreen), findsNothing);
        expect(produtos.edicoes, hasLength(1));
        expect(find.text('Banana nanica'), findsOneWidget);
        expect(pagina.temMudancas, isTrue);
        expect(estrutura.pedidos, isEmpty);
        expect(tester.widget<ElevatedButton>(_publicar).onPressed, isNotNull);
      },
    );

    testWidgets(
      'Cenário: Dado o produto indisponível na API, quando toco nele, então aviso de erro e o formulário não abre',
      (tester) async {
        produtos.falhaSimulada = const FalhaSemConexao();
        await abrir(tester);

        await tester.tap(find.text('Banana prata'));
        await tester.pumpAndSettle();

        expect(find.byType(ProdutoFormScreen), findsNothing);
        expect(
          find.text('Sem conexão. Verifique a internet e tente de novo.'),
          findsOneWidget,
        );
      },
    );
  });
}
