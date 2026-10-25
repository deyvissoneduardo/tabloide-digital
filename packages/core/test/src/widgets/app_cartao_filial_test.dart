import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: cartão de filial', () {
    testWidgets(
      'Cenário: Dado uma filial, então mostra nome e endereço resumido',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(AppCartaoFilial(filial: filialFake)),
        );

        expect(find.text('Centro'), findsOneWidget);
        expect(
          find.text('Rua das Flores, 120 · Centro, Campinas/SP'),
          findsOneWidget,
        );
        expect(find.text('Em uso'), findsNothing);
        expect(find.byType(PopupMenuButton<AcaoFilial>), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado a filial em uso com ações, quando abro o menu, então não ofereço "Usar" e repasso a ação escolhida',
      (tester) async {
        final acoes = <AcaoFilial>[];
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoFilial(
              filial: filialFake,
              emUso: true,
              aoEscolherAcao: acoes.add,
            ),
          ),
        );

        expect(find.text('Em uso'), findsOneWidget);
        await tester.tap(find.byTooltip('Ações da filial Centro'));
        await tester.pumpAndSettle();
        expect(find.text('Usar esta filial'), findsNothing);
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();

        expect(acoes, [AcaoFilial.editar]);
      },
    );

    testWidgets(
      'Cenário: Dado a única filial, quando abro o menu, então "Excluir" fica desabilitado e explica o motivo',
      (tester) async {
        final acoes = <AcaoFilial>[];
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoFilial(
              filial: filialFake,
              podeExcluir: false,
              aoEscolherAcao: acoes.add,
            ),
          ),
        );

        await tester.tap(find.byTooltip('Ações da filial Centro'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir (mantenha ao menos uma filial)'));
        await tester.pumpAndSettle();

        expect(acoes, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado um cartão tocável, quando toco, então aviso quem chamou',
      (tester) async {
        var toques = 0;
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoFilial(filial: filialFake, aoTocar: () => toques++),
          ),
        );

        await tester.tap(find.text('Centro'));

        expect(toques, 1);
      },
    );
  });
}
