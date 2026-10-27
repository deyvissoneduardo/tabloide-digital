import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

PanfletoResponse _naoEditavel() => PanfletoResponse(
  id: panfletoFake.id,
  filialId: panfletoFake.filialId,
  tipo: panfletoFake.tipo,
  urlArquivo: panfletoFake.urlArquivo,
  largura: panfletoFake.largura,
  altura: panfletoFake.altura,
  vigencia: Vigencia(
    dataInicio: panfletoFake.vigencia.dataInicio,
    dataLimite: panfletoFake.vigencia.dataLimite,
    situacao: SituacaoVigencia.vigente,
    editavel: false,
  ),
  criadoEm: panfletoFake.criadoEm,
);

void main() {
  group('Funcionalidade: cartão de panfleto', () {
    testWidgets(
      'Cenário: Dado um panfleto vigente com data limite, então mostra a situação, desde quando e "válido até dd/mm"',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(AppCartaoPanfleto(panfleto: panfletoFake)),
        );

        expect(find.text('Vigente desde 18/10/2026'), findsOneWidget);
        expect(find.text('Válido até 31/10'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Panfleto vigente de 18/10/2026'),
          findsOneWidget,
        );
        expect(find.byType(PopupMenuButton<AcaoPanfleto>), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto agendado sem data limite, então mostra quando começa e "Sem data limite"',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(AppCartaoPanfleto(panfleto: panfletoFakeAgendado)),
        );

        expect(find.text('Agendado para 01/11/2026'), findsOneWidget);
        expect(find.text('Sem data limite'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado ações, quando escolho "Editar", então repasso a ação',
      (tester) async {
        final acoes = <AcaoPanfleto>[];
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoPanfleto(
              panfleto: panfletoFake,
              aoEscolherAcao: acoes.add,
            ),
          ),
        );

        await tester.tap(find.byTooltip('Ações do panfleto de 18/10/2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();

        expect(acoes, [AcaoPanfleto.editar]);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto não editável, quando abro o menu, então só ofereço "Excluir" (RN26)',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoPanfleto(panfleto: _naoEditavel(), aoEscolherAcao: (_) {}),
          ),
        );

        await tester.tap(find.byTooltip('Ações do panfleto de 18/10/2026'));
        await tester.pumpAndSettle();

        expect(find.text('Editar'), findsNothing);
        expect(find.text('Excluir'), findsOneWidget);
      },
    );
  });
}
