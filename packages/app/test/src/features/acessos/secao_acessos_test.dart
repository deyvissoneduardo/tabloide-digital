import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: painel de acessos na home do app', () {
    Future<(AcessosController, AcessosRepositoryFake)> abrir(
      WidgetTester tester, {
      AcessosRepositoryFake? repository,
      List<FilialResponse>? filiais,
    }) async {
      tester.view.physicalSize = const Size(400, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final acessos = repository ?? AcessosRepositoryFake();
      final listaFiliais = filiais ?? [filialFake, filialFakeBairro];
      final filiaisController = filiaisControllerDeTeste(
        repository: FilialRepositoryFake(filiais: listaFiliais),
      );
      await tester.runAsync(filiaisController.carregar);
      final controller = acessosControllerDeTeste(repository: acessos);
      await tester.pumpWidget(
        montarTela(
          Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(AppEspacamentos.md),
              children: const [SecaoAcessos()],
            ),
          ),
          filiais: filiaisController,
          acessos: controller,
        ),
      );
      final carregou = controller.filiaisMudaram([
        for (final filial in listaFiliais) filial.id,
      ]);
      await tester.pumpAndSettle();
      await carregou;
      await tester.pumpAndSettle();
      return (controller, acessos);
    }

    testWidgets(
      'Cenário: Dado o resumo demorando, quando abro, então vejo o esqueleto',
      (tester) async {
        tester.view.physicalSize = const Size(400, 3200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          montarTela(
            const Scaffold(body: SingleChildScrollView(child: SecaoAcessos())),
          ),
        );

        expect(find.byType(Esqueleto), findsNWidgets(3));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Cenário: Dado 2 filiais e uma excluída com acessos, quando abro, então vejo total, gráfico, pico, ranking com o selo e a dica dos panfletos',
      (tester) async {
        await abrir(tester);

        expect(find.text('Acessos à sua página'), findsOneWidget);
        expect(find.text('1.925'), findsOneWidget);
        expect(find.text('Últimos 30 dias'), findsOneWidget);
        expect(find.byType(AppGraficoAcessosDia), findsOneWidget);
        expect(
          find.text('Mais movimento: sábado, entre 18h e 19h.'),
          findsOneWidget,
        );
        expect(find.text('Acessos por filial'), findsOneWidget);
        expect(find.text('Filial excluída'), findsOneWidget);
        expect(find.text('Filial'), findsOneWidget);
        expect(
          find.text(
            'Escolha uma filial no filtro acima para comparar os panfletos.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado 1 filial só, quando abro, então não há ranking nem seletor de filial e os panfletos dela aparecem',
      (tester) async {
        await abrir(
          tester,
          filiais: [filialFake],
          repository: AcessosRepositoryFake(resumo: resumoAcessosPoucosFake),
        );

        expect(find.text('Acessos por filial'), findsNothing);
        expect(find.text('Filial'), findsNothing);
        expect(find.byType(AppCartaoAcessosPanfleto), findsNWidgets(2));
        expect(find.text('Melhor média'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado menos de 100 acessos, quando abro, então o pico mostra "ainda não há acessos suficientes"',
      (tester) async {
        await abrir(
          tester,
          repository: AcessosRepositoryFake(resumo: resumoAcessosPoucosFake),
        );

        expect(
          find.text(
            'Ainda não há acessos suficientes para mostrar os horários de pico '
            '(mínimo de 100 no período).',
          ),
          findsOneWidget,
        );
        expect(find.byType(AppGraficoBarras), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado nenhum acesso no período, quando abro, então vejo o estado vazio',
      (tester) async {
        await abrir(
          tester,
          repository: AcessosRepositoryFake(resumo: resumoAcessosVazioFake),
        );

        expect(find.text('Ainda não há acessos neste período'), findsOneWidget);
        expect(find.byType(AppGraficoAcessosDia), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado sem conexão, quando abro e toco em "Tentar de novo" com a conexão de volta, então vejo os números',
      (tester) async {
        final repository = AcessosRepositoryFake(
          falhaSimulada: const FalhaSemConexao(),
        );
        await abrir(tester, repository: repository);

        expect(find.text(const FalhaSemConexao().mensagem), findsOneWidget);

        repository.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.text('1.925'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado 2 filiais, quando escolho "Bairro Alto" no filtro, então os panfletos dela aparecem com "Melhor média"',
      (tester) async {
        final (controller, repository) = await abrir(tester);

        await tester.tap(find.text('Todas as filiais'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bairro Alto').last);
        await tester.pumpAndSettle();

        expect(controller.filialId, filialFakeBairro.id);
        expect(repository.pedidos.last, (
          periodo: PeriodoAcessos.padrao,
          filialId: filialFakeBairro.id,
          panfletos: true,
        ));
        expect(find.byType(AppCartaoAcessosPanfleto), findsNWidgets(2));
        expect(find.text('Melhor média'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o padrão de 30 dias, quando toco em "Hoje", então o controller pede o período de 1 dia',
      (tester) async {
        final (controller, repository) = await abrir(tester);

        await tester.tap(find.text('Hoje'));
        await tester.pumpAndSettle();

        expect(controller.periodo, const PeriodoPredefinido(1));
        expect(repository.pedidos.last.periodo, const PeriodoPredefinido(1));
        expect(find.text('Hoje'), findsNWidgets(2));
      },
    );
  });

  testWidgets(
    'Cenário: Dado a home, quando as filiais carregam, então o painel de acessos pede o resumo uma vez',
    (tester) async {
      final repository = AcessosRepositoryFake();
      await tester.pumpWidget(
        montarTela(
          const HomeScreen(),
          acessos: acessosControllerDeTeste(repository: repository),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      }

      expect(repository.pedidos, [
        (periodo: PeriodoAcessos.padrao, filialId: null, panfletos: false),
        (
          periodo: PeriodoAcessos.padrao,
          filialId: filialFake.id,
          panfletos: true,
        ),
      ]);
    },
  );
}
