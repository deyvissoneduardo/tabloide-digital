import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

ProdutoResponse _naoEditavel() => ProdutoResponse(
  id: produtoFake.id,
  filialId: produtoFake.filialId,
  categoria: produtoFake.categoria,
  nome: produtoFake.nome,
  precoPromocionalCentavos: produtoFake.precoPromocionalCentavos,
  vigencia: Vigencia(
    dataInicio: produtoFake.vigencia.dataInicio,
    situacao: SituacaoVigencia.vigente,
    editavel: false,
  ),
  criadoEm: produtoFake.criadoEm,
  atualizadoEm: produtoFake.atualizadoEm,
);

void main() {
  group('Funcionalidade: cartão de produto', () {
    testWidgets(
      'Cenário: Dado um produto vigente com preço original, então mostra nome, quantidade, "de/por" e "válido até dd/mm" (RN32)',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(AppCartaoProduto(produto: produtoFake)),
        );

        expect(find.text('Arroz Tipo 1 · 5kg'), findsOneWidget);
        expect(
          find.text('de R\$ 26,49 por R\$ 21,99\nVigente · válido até 25/10'),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('Foto de Arroz Tipo 1'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um produto agendado sem preço original nem foto, então mostra só o preço e quando começa',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoProduto(
              produto: ProdutoResponse(
                id: 'p1',
                filialId: 'f1',
                categoria: produtoFakeAgendado.categoria,
                nome: 'Suco',
                precoPromocionalCentavos: 599,
                vigencia: produtoFakeAgendado.vigencia,
                criadoEm: DateTime.utc(2026),
                atualizadoEm: DateTime.utc(2026),
              ),
            ),
          ),
        );

        expect(find.text('Suco'), findsOneWidget);
        expect(
          find.text('R\$ 5,99\nAgendado para 01/11/2026 · sem data limite'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um produto não editável, quando abro as ações, então só existe "Excluir" (RN26)',
      (tester) async {
        final acoes = <AcaoProduto>[];
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoProduto(
              produto: _naoEditavel(),
              aoEscolherAcao: acoes.add,
            ),
          ),
        );

        await tester.tap(find.byTooltip('Ações do produto Arroz Tipo 1'));
        await tester.pumpAndSettle();

        expect(find.text('Editar'), findsNothing);
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();
        expect(acoes, [AcaoProduto.excluir]);
      },
    );

    testWidgets(
      'Cenário: Dado um produto editável, quando escolho "Editar", então repasso a ação',
      (tester) async {
        final acoes = <AcaoProduto>[];
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoProduto(produto: produtoFake, aoEscolherAcao: acoes.add),
          ),
        );

        await tester.tap(find.byTooltip('Ações do produto Arroz Tipo 1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();

        expect(acoes, [AcaoProduto.editar]);
      },
    );
  });
}
