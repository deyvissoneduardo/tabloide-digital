import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: filtro de período dos acessos', () {
    testWidgets(
      'Cenário: Dado o padrão de 30 dias, quando toco em "7 dias", então recebo o período de 7 dias',
      (tester) async {
        final escolhidos = <PeriodoAcessos>[];
        await tester.pumpWidget(
          montarComMarca(
            AppFiltroPeriodo(
              valor: PeriodoAcessos.padrao,
              aoMudar: escolhidos.add,
              hoje: DateTime(2026, 11, 9),
            ),
          ),
        );

        expect(
          tester
              .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '30 dias'))
              .selected,
          isTrue,
        );
        await tester.tap(find.text('7 dias'));
        await tester.tap(find.text('30 dias'));

        expect(escolhidos, [const PeriodoPredefinido(7)]);
      },
    );

    testWidgets(
      'Cenário: Dado um período personalizado, então o chip mostra as datas',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppFiltroPeriodo(
              valor: PeriodoPersonalizado(
                DateTime(2026, 10, 1),
                DateTime(2026, 10, 31),
              ),
              aoMudar: (_) {},
              hoje: DateTime(2026, 11, 9),
            ),
          ),
        );

        expect(find.text('01/10 – 31/10'), findsOneWidget);
        expect(find.text('Personalizado'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado o seletor de período, quando escolho de 01/11 a 05/11 e aplico, então recebo o período personalizado',
      (tester) async {
        final escolhidos = <PeriodoAcessos>[];
        await tester.pumpWidget(
          montarComMarca(
            AppFiltroPeriodo(
              valor: PeriodoAcessos.padrao,
              aoMudar: escolhidos.add,
              hoje: DateTime(2026, 11, 9),
            ),
          ),
        );

        await tester.tap(find.text('Personalizado'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Switch to input'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0), '11/01/2026');
        await tester.enterText(find.byType(TextField).at(1), '11/05/2026');
        await tester.tap(find.text('Aplicar'));
        await tester.pumpAndSettle();

        expect(escolhidos, [
          PeriodoPersonalizado(DateTime(2026, 11, 1), DateTime(2026, 11, 5)),
        ]);
      },
    );
  });

  group('Funcionalidade: indicadores de acessos', () {
    testWidgets(
      'Cenário: Dado 1925 acessos, então o indicador mostra "1.925" com o apoio',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const AppIndicadorNumero(
              rotulo: 'Acessos',
              valor: 1925,
              apoio: 'Últimos 30 dias',
            ),
          ),
        );

        expect(find.text('1.925'), findsOneWidget);
        expect(find.text('Últimos 30 dias'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado uma filial excluída no ranking, então ela aparece com o selo "Filial excluída"',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppRankingFiliais(filiais: resumoAcessosFake.porFilial),
          ),
        );

        expect(find.text('Centro'), findsOneWidget);
        expect(find.text('1.265'), findsOneWidget);
        expect(find.text('Filial excluída'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
      },
    );

    testWidgets(
      'Cenário: Dado os acessos por dia, então o gráfico anuncia o total e o maior dia',
      (tester) async {
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(
          montarComMarca(
            AppGraficoAcessosDia(
              dias: resumoAcessosFake.porDia,
              marcadores: [
                for (final inicio in resumoAcessosFake.iniciosPanfleto)
                  inicio.data,
              ],
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            'Acessos por dia, total 1.925, maior dia 30/10 com 120',
          ),
          findsOneWidget,
        );
        expect(find.text('Novo panfleto'), findsOneWidget);
        semantica.dispose();
      },
    );

    testWidgets(
      'Cenário: Dado só um dia (Hoje), então o gráfico vira o número escrito',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppGraficoAcessosDia(
              dias: [
                AcessosDiaResponse(data: DateTime(2026, 11, 9), total: 1234),
              ],
              marcadores: const [],
            ),
          ),
        );

        expect(find.text('1.234'), findsOneWidget);
        expect(find.text('acessos em 09/11'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado acessos por dia da semana, então as barras anunciam o dia de maior movimento',
      (tester) async {
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(
          montarComMarca(
            const AppGraficoBarras(
              valores: [210, 190, 200, 230, 310, 400, 300],
              rotulos: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
              descricao: 'Por dia da semana',
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            'Por dia da semana: maior movimento em Sáb, com 400 acessos',
          ),
          findsOneWidget,
        );
        semantica.dispose();
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto com a melhor média, então o cartão mostra período, média e o selo',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoAcessosPanfleto(
              item: panfletosAcessosFake.itens.first,
              melhorMedia: true,
            ),
          ),
        );

        expect(find.text('20/10 a 15/11'), findsOneWidget);
        expect(find.text('Vigente'), findsOneWidget);
        expect(find.text('980 acessos · 46,7 por dia'), findsOneWidget);
        expect(find.text('Melhor média'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto vencido, então o período vai até o fim da contagem e não há selo',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCartaoAcessosPanfleto(
              item: panfletosAcessosFake.itens.last,
              melhorMedia: false,
            ),
          ),
        );

        expect(find.text('01/10 a 19/10'), findsOneWidget);
        expect(find.text('Encerrado'), findsOneWidget);
        expect(find.text('Melhor média'), findsNothing);
      },
    );
  });
}
