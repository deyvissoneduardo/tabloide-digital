import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: seção Produtos da home na web', () {
    late ProdutoRepositoryFake produtos;
    late CategoriaRepositoryFake categorias;

    Future<void> abrir(
      WidgetTester tester, {
      List<ProdutoResponse> listaProdutos = const [],
      List<CategoriaResponse> listaCategorias = const [],
      FiliaisController? filiais,
    }) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      produtos = ProdutoRepositoryFake(produtos: listaProdutos);
      categorias = CategoriaRepositoryFake(categorias: listaCategorias);
      final controllerFiliais = filiais ?? filiaisControllerDeTeste();
      if (filiais == null) await tester.runAsync(controllerFiliais.carregar);
      await tester.pumpWidget(
        montarTela(
          const HomeScreen(),
          home: controllerDeTeste()..selecionar(SecaoPainel.produtos),
          filiais: controllerFiliais,
          produtoRepository: produtos,
          categoriaRepository: categorias,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado produtos de duas categorias, então agrupo por categoria em ordem alfabética com "Novo produto" e "Categorias"',
      (tester) async {
        await abrir(
          tester,
          listaProdutos: [produtoFake, produtoFakeAgendado],
          listaCategorias: [categoriaFake, categoriaFakeVazia],
        );

        double topo(String texto) => tester.getTopLeft(find.text(texto)).dy;
        expect(topo('Bebidas'), lessThan(topo('Refrigerante cola · 2 L')));
        expect(topo('Refrigerante cola · 2 L'), lessThan(topo('Mercearia')));
        expect(topo('Mercearia'), lessThan(topo('Arroz Tipo 1 · 5kg')));
        expect(
          find.widgetWithText(ElevatedButton, 'Novo produto'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(OutlinedButton, 'Categorias'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado nenhuma categoria, então oriento criar a primeira categoria (RN19)',
      (tester) async {
        await abrir(tester);

        expect(find.text('Crie a primeira categoria'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Nova categoria'));
        await tester.pumpAndSettle();

        expect(find.byType(CategoriaFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado categorias sem produtos, então mostro o estado vazio com "Novo produto" e o acesso a Categorias',
      (tester) async {
        await abrir(tester, listaCategorias: [categoriaFakeVazia]);

        expect(
          find.text('Nenhum produto na filial ${filialFake.nome}'),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Novo produto'));
        await tester.pumpAndSettle();

        expect(find.byType(ProdutoFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a lista, quando abro Categorias e volto, então recarrego os produtos',
      (tester) async {
        await abrir(
          tester,
          listaProdutos: [produtoFake],
          listaCategorias: [categoriaFake],
        );

        await tester.tap(find.widgetWithText(OutlinedButton, 'Categorias'));
        await tester.pumpAndSettle();
        expect(find.byType(CategoriasScreen), findsOneWidget);
        produtos.produtos.clear();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(find.byType(AppCartaoProduto), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado um produto, quando excluo e confirmo, então ele sai da lista',
      (tester) async {
        await abrir(
          tester,
          listaProdutos: [produtoFake],
          listaCategorias: [categoriaFake],
        );

        await tester.tap(find.byTooltip('Ações do produto Arroz Tipo 1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();
        expect(find.text('Excluir Arroz Tipo 1?'), findsOneWidget);
        await tester.tap(find.text('Excluir produto'));
        await tester.pumpAndSettle();

        expect(produtos.excluidos, [produtoFake.id]);
        expect(find.text('Produto excluído.'), findsOneWidget);
        expect(find.byType(AppCartaoProduto), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado um produto, quando toco nele, então abro a edição',
      (tester) async {
        await abrir(
          tester,
          listaProdutos: [produtoFake],
          listaCategorias: [categoriaFake],
        );

        await tester.tap(find.text('Arroz Tipo 1 · 5kg'));
        await tester.pumpAndSettle();

        expect(find.text('Editar produto'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado falha ao carregar, quando toco "Tentar de novo", então recarrego',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        produtos = ProdutoRepositoryFake(
          produtos: [produtoFake],
          falhaSimulada: const FalhaSemConexao(),
        );
        final filiais = filiaisControllerDeTeste();
        await tester.runAsync(filiais.carregar);
        await tester.pumpWidget(
          montarTela(
            const HomeScreen(),
            home: controllerDeTeste()..selecionar(SecaoPainel.produtos),
            filiais: filiais,
            produtoRepository: produtos,
            categoriaRepository: CategoriaRepositoryFake(
              categorias: [categoriaFake],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EstadoFalha), findsOneWidget);

        produtos.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.byType(AppCartaoProduto), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado nenhuma filial em uso, então peço para escolher a filial',
      (tester) async {
        await abrir(
          tester,
          filiais: filiaisControllerDeTeste(
            repository: FilialRepositoryFake(filiais: []),
          ),
        );

        expect(find.text('Escolha uma filial'), findsOneWidget);
      },
    );
  });
}
