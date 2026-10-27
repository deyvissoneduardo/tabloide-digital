import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _desativado = FalhaApi(
  codigo: 'LOJISTA_DESATIVADO',
  mensagem: 'Sua conta está desativada.',
);

Finder get _publicar => find.widgetWithText(ElevatedButton, 'Publicar ordem');

void main() {
  group('Funcionalidade: Seção Página', () {
    late EstruturaRepositoryFake estrutura;
    late HomeController home;
    late PaginaController pagina;

    setUp(() {
      estrutura = EstruturaRepositoryFake();
      pagina = paginaControllerDeTeste(estrutura: estrutura);
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
      'Cenário: Dado sem mudanças, quando desenho, então "Publicar ordem" está desabilitado',
      (tester) async {
        await abrir(tester);

        expect(tester.widget<ElevatedButton>(_publicar).onPressed, isNull);
      },
    );

    testWidgets(
      'Cenário: Dado mudanças, quando toco em "Publicar ordem", então aparece o spinner no botão e depois o aviso de sucesso',
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
          find.text('Ordem publicada. A página atualiza em até 1 minuto.'),
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
          find.text('Conta desativada: a ordem não pode ser alterada.'),
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
        'Cenário: Dado $nome, quando abro, então há TabBar "Montar" e "Prévia" (D12, app sempre em abas)',
        (tester) async {
          await abrir(tester, tamanho: tamanho);

          expect(find.byType(TabBar), findsOneWidget);
          expect(find.text('Montar'), findsOneWidget);
          expect(find.text('Prévia'), findsOneWidget);
        },
      );
    }
  });
}
