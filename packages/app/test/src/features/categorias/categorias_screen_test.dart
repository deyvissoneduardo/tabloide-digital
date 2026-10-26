import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: tela de categorias no app', () {
    late CategoriaRepositoryFake repository;

    Future<void> abrir(
      WidgetTester tester,
      List<CategoriaResponse> categorias,
    ) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      repository = CategoriaRepositoryFake(categorias: categorias);
      await tester.pumpWidget(
        montarTela(
          CategoriasScreen(filialId: filialFake.id),
          categoriaRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> acao(WidgetTester tester, String nome, String acao) async {
      await tester.tap(find.byTooltip('Ações da categoria $nome'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(acao));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado duas categorias, então lista em ordem alfabética com as contagens e "Nova categoria"',
      (tester) async {
        await abrir(tester, [categoriaFake, categoriaFakeVazia]);

        final cartoes = tester
            .widgetList<AppCartaoCategoria>(find.byType(AppCartaoCategoria))
            .map((c) => c.categoria.nome);
        expect(cartoes, ['Bebidas', 'Mercearia']);
        expect(
          find.widgetWithText(ElevatedButton, 'Nova categoria'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado nenhuma categoria, então mostra o estado vazio com "Nova categoria"',
      (tester) async {
        await abrir(tester, []);

        expect(find.text('Nenhuma categoria ainda'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Nova categoria'));
        await tester.pumpAndSettle();

        expect(find.byType(CategoriaFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado uma categoria com vencidos, quando excluo, então a confirmação avisa que eles vão junto (RN20) e a categoria sai',
      (tester) async {
        await abrir(tester, [categoriaFake, categoriaFakeVazia]);

        await acao(tester, 'Bebidas', 'Excluir');

        expect(find.text('Excluir a categoria Bebidas?'), findsOneWidget);
        expect(
          find.text(
            'Os produtos vencidos desta categoria também serão excluídos.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Excluir categoria'));
        await tester.pumpAndSettle();

        expect(repository.excluidos, [categoriaFakeVazia.id]);
        expect(find.text('Categoria excluída.'), findsOneWidget);
        expect(find.text('Bebidas'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado a confirmação cancelada, quando excluo, então nada é enviado',
      (tester) async {
        await abrir(tester, [categoriaFakeVazia]);

        await acao(tester, 'Bebidas', 'Excluir');
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(repository.excluidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando a exclusão, quando confirmo, então aviso o motivo',
      (tester) async {
        await abrir(tester, [categoriaFakeVazia]);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'CATEGORIA_COM_PRODUTOS_ATIVOS',
          mensagem: 'Exclua os produtos vigentes e agendados antes de excluir a categoria.',
        );

        await acao(tester, 'Bebidas', 'Excluir');
        await tester.tap(find.text('Excluir categoria'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Exclua os produtos vigentes e agendados antes de excluir a categoria.',
          ),
          findsOneWidget,
        );
        expect(find.byType(AppCartaoCategoria), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado uma categoria, quando escolho "Renomear" e salvo, então a lista mostra o nome novo',
      (tester) async {
        await abrir(tester, [categoriaFakeVazia]);

        await acao(tester, 'Bebidas', 'Renomear');
        expect(find.text('Renomear categoria'), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome da categoria'),
          'Bebidas geladas',
        );
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Salvar categoria'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Categoria salva.'), findsOneWidget);
        expect(find.text('Bebidas geladas'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado falha ao carregar, quando toco "Tentar de novo", então recarrego',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        repository = CategoriaRepositoryFake(
          categorias: [categoriaFake],
          falhaSimulada: const FalhaSemConexao(),
        );
        await tester.pumpWidget(
          montarTela(
            CategoriasScreen(filialId: filialFake.id),
            categoriaRepository: repository,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EstadoFalha), findsOneWidget);

        repository.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.byType(AppCartaoCategoria), findsOneWidget);
      },
    );
  });
}
