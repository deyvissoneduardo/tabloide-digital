import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';

import '../../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: escolha de UF em bottom sheet no app', () {
    testWidgets(
      'Cenário: Dado a UF atual, quando abro o seletor, então ela vem marcada; quando toco em outra, então devolvo a escolhida',
      (tester) async {
        Uf? escolhida;
        await tester.pumpWidget(
          montarTela(
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async =>
                      escolhida = await showModalBottomSheet<Uf>(
                        context: context,
                        builder: (_) => const SeletorUf(selecionada: Uf.ac),
                      ),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        expect(find.text('Escolha a UF'), findsOneWidget);
        expect(
          find.descendant(
            of: find.widgetWithText(ListTile, 'AC · Acre'),
            matching: find.byIcon(Icons.check),
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('AM · Amazonas'));
        await tester.pumpAndSettle();

        expect(escolhida, Uf.am);
        expect(find.text('Escolha a UF'), findsNothing);
      },
    );
  });
}
