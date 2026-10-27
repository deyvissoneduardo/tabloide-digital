import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

Widget _editor({
  required CategoriaEstruturaResponse categoria,
  bool habilitado = true,
  void Function(int, int)? aoMoverProduto,
  VoidCallback? aoSubir,
  VoidCallback? aoDescer,
}) => montarComMarca(
  SizedBox(
    width: 400,
    height: 600,
    child: ReorderableListView(
      buildDefaultDragHandles: false,
      onReorderItem: (_, _) {},
      children: [
        AppEditorCategoria(
          key: ValueKey(categoria.id),
          categoria: categoria,
          indice: 0,
          habilitado: habilitado,
          aoMoverProduto: aoMoverProduto ?? (_, _) {},
          aoSubir: aoSubir,
          aoDescer: aoDescer,
        ),
      ],
    ),
  ),
);

Finder _semanticaDa(String nome) =>
    find.byWidgetPredicate((w) => w is Semantics && w.properties.label == nome);

void main() {
  group('Funcionalidade: Editor da página', () {
    final hortifruti = estruturaFake.categorias.first;

    testWidgets(
      'Cenário: Dado habilitado, quando desenho, então há alça de arrastar na categoria e em cada produto',
      (tester) async {
        await tester.pumpWidget(_editor(categoria: hortifruti));

        expect(find.byIcon(Icons.drag_indicator), findsNWidgets(3));
        expect(find.text('2 produtos'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado desabilitado, quando desenho, então não há alças nem ações',
      (tester) async {
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(
          _editor(categoria: hortifruti, habilitado: false, aoDescer: () {}),
        );

        expect(find.byIcon(Icons.drag_indicator), findsNothing);
        final dados = tester
            .getSemantics(_semanticaDa('Hortifrúti'))
            .getSemanticsData();
        expect(dados.customSemanticsActionIds ?? const <int>[], isEmpty);
        semantica.dispose();
      },
    );

    testWidgets(
      'Cenário: Dado a ação semântica "Mover para baixo", quando aciono, então aoDescer é chamado',
      (tester) async {
        final semantica = tester.ensureSemantics();
        var descidas = 0;
        await tester.pumpWidget(
          _editor(categoria: hortifruti, aoDescer: () => descidas++),
        );

        tester.semantics.customAction(
          find.semantics.byLabel(RegExp('^Hortifrúti')),
          const CustomSemanticsAction(label: 'Mover para baixo'),
        );

        expect(descidas, 1);
        semantica.dispose();
      },
    );

    testWidgets(
      'Cenário: Dado arrasto de um produto para a direita, quando solto, então aoMoverProduto recebe (de, para) do ReorderableListView',
      (tester) async {
        final movimentos = <(int, int)>[];
        await tester.pumpWidget(
          _editor(
            categoria: hortifruti,
            aoMoverProduto: (de, para) => movimentos.add((de, para)),
          ),
        );

        final alca = find.descendant(
          of: find.widgetWithText(AppEditorProduto, 'Banana prata'),
          matching: find.byIcon(Icons.drag_indicator),
        );
        final gesto = await tester.startGesture(tester.getCenter(alca));
        for (var i = 0; i < 10; i++) {
          await gesto.moveBy(
            const Offset(AppLayout.larguraCartaoProdutoEditor * 0.15, 0),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        await gesto.up();
        await tester.pumpAndSettle();

        expect(movimentos, [(0, 1)]);
      },
    );

    testWidgets(
      'Cenário: Dado categoria sem produtos, quando desenho, então "Sem produtos vigentes ou agendados"',
      (tester) async {
        await tester.pumpWidget(
          _editor(
            categoria: const CategoriaEstruturaResponse(
              id: 'c',
              nome: 'Bebidas',
              produtos: [],
            ),
          ),
        );

        expect(find.text('Sem produtos vigentes ou agendados'), findsOneWidget);
        expect(find.text('0 produtos'), findsOneWidget);
      },
    );
  });
}
