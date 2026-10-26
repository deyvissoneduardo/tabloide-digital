import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: nome da marca', () {
    testWidgets(
      'Cenário: Dado o painel, quando o nome aparece, então mostro "Tabloide Digital"',
      (tester) async {
        await tester.pumpWidget(montarComMarca(const MarcaNome()));

        expect(find.text('Tabloide Digital'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado pouco espaço, quando o nome aparece, então o texto fica em uma linha com reticências',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(const SizedBox(width: 80, child: MarcaNome())),
        );

        final texto = tester.widget<Text>(find.byType(Text));
        expect(texto.maxLines, 1);
        expect(texto.overflow, TextOverflow.ellipsis);
      },
    );
  });
}
