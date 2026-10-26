import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: cartão de categoria', () {
    testWidgets(
      'Cenário: Dado uma categoria com produtos, então mostra o nome e as contagens por situação',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(AppCartaoCategoria(categoria: categoriaFake)),
        );

        expect(find.text('Mercearia'), findsOneWidget);
        expect(
          find.text('12 vigentes · 3 agendados · 7 vencidos'),
          findsOneWidget,
        );
        expect(find.byType(PopupMenuButton<AcaoCategoria>), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado uma categoria sem produtos, então mostra "Nenhum produto"',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoCategoria(
              categoria: CategoriaResponse(
                id: 'c1',
                nome: 'Padaria',
                produtos: const ContagemProdutos(
                  vigentes: 0,
                  agendados: 0,
                  vencidos: 0,
                ),
                podeExcluir: true,
                criadoEm: DateTime.utc(2026),
                atualizadoEm: DateTime.utc(2026),
              ),
            ),
          ),
        );

        expect(find.text('Nenhum produto'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado uma categoria com produtos ativos, quando abro as ações, então "Excluir" fica desabilitado com o motivo (RN20)',
      (tester) async {
        final acoes = <AcaoCategoria>[];
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoCategoria(
              categoria: categoriaFake,
              aoEscolherAcao: acoes.add,
            ),
          ),
        );

        await tester.tap(find.byTooltip('Ações da categoria Mercearia'));
        await tester.pumpAndSettle();
        final excluir = tester.widget<PopupMenuItem<AcaoCategoria>>(
          find.ancestor(
            of: find.text(
              'Excluir (exclua antes os produtos vigentes e agendados)',
            ),
            matching: find.byType(PopupMenuItem<AcaoCategoria>),
          ),
        );
        expect(excluir.enabled, isFalse);
        await tester.tap(find.text('Renomear'));
        await tester.pumpAndSettle();

        expect(acoes, [AcaoCategoria.renomear]);
      },
    );

    testWidgets(
      'Cenário: Dado uma categoria que pode ser excluída, quando escolho "Excluir", então repasso a ação',
      (tester) async {
        final acoes = <AcaoCategoria>[];
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoCategoria(
              categoria: categoriaFakeVazia,
              aoEscolherAcao: acoes.add,
            ),
          ),
        );

        expect(find.text('2 vencidos'), findsOneWidget);
        await tester.tap(find.byTooltip('Ações da categoria Bebidas'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();

        expect(acoes, [AcaoCategoria.excluir]);
      },
    );
  });
}
