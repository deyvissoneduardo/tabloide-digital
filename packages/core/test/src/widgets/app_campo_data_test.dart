import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: campo de data só de dia', () {
    final primeira = DateTime(2026, 10, 26);
    final ultima = DateTime(2026, 12, 31);

    Widget campo({
      DateTime? valor,
      ValueChanged<DateTime>? aoMudar,
      VoidCallback? aoLimpar,
      bool habilitado = true,
      FormFieldValidator<DateTime>? validador,
      GlobalKey<FormState>? chave,
    }) => montarComMarca(
      Form(
        key: chave,
        child: AppCampoData(
          rotulo: 'Data limite',
          valor: valor,
          primeiraData: primeira,
          ultimaData: ultima,
          aoMudar: aoMudar ?? (_) {},
          aoLimpar: aoLimpar,
          habilitado: habilitado,
          validador: validador,
          dica: 'Sem data: vale até ser excluído.',
        ),
      ),
    );

    testWidgets('Cenário: Dado uma data, então mostra dd/mm/aaaa e a dica', (
      tester,
    ) async {
      await tester.pumpWidget(campo(valor: DateTime(2026, 11, 5)));

      expect(find.text('05/11/2026'), findsOneWidget);
      expect(find.text('Sem data: vale até ser excluído.'), findsOneWidget);
    });

    testWidgets(
      'Cenário: Dado o campo vazio, quando toco e escolho um dia, então devolvo o dia sem hora',
      (tester) async {
        final escolhidas = <DateTime>[];
        await tester.pumpWidget(campo(aoMudar: escolhidas.add));

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsOneWidget);
        await tester.tap(find.text('28'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(escolhidas, [DateTime(2026, 10, 28)]);
      },
    );

    testWidgets(
      'Cenário: Dado o campo num formulário, quando escolho um dia e o pai guarda a data, então o campo mostra a nova data sem erro de build',
      (tester) async {
        DateTime? escolhida;
        await tester.pumpWidget(
          montarComMarca(
            StatefulBuilder(
              builder: (context, setState) => Form(
                child: AppCampoData(
                  rotulo: 'Data limite',
                  valor: escolhida,
                  primeiraData: primeira,
                  ultimaData: ultima,
                  aoMudar: (data) => setState(() => escolhida = data),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();
        await tester.tap(find.text('28'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('28/10/2026'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o calendário aberto, quando cancelo, então nada muda',
      (tester) async {
        final escolhidas = <DateTime>[];
        await tester.pumpWidget(campo(aoMudar: escolhidas.add));

        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(escolhidas, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado o campo desabilitado, quando toco, então o calendário não abre',
      (tester) async {
        await tester.pumpWidget(
          campo(valor: DateTime(2026, 10, 18), habilitado: false),
        );

        await tester.tap(find.byType(TextFormField), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado uma data e "limpar" disponível, quando limpo, então aviso quem chamou',
      (tester) async {
        var limpezas = 0;
        await tester.pumpWidget(
          campo(valor: DateTime(2026, 11, 5), aoLimpar: () => limpezas++),
        );

        await tester.tap(find.byTooltip('Limpar data limite'));

        expect(limpezas, 1);
      },
    );

    testWidgets(
      'Cenário: Dado um validador, quando o formulário valida, então o erro aparece no próprio campo',
      (tester) async {
        final chave = GlobalKey<FormState>();
        await tester.pumpWidget(
          campo(
            chave: chave,
            validador: (data) => data == null ? 'Escolha a data.' : null,
          ),
        );

        chave.currentState!.validate();
        await tester.pump();

        expect(find.text('Escolha a data.'), findsOneWidget);
      },
    );
  });
}
