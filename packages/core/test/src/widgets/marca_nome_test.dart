import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: nome da marca', () {
    testWidgets(
      'Cenário: Dado a marca "Padaria Central", quando o nome aparece, então mostro o nome da marca',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const MarcaNome(),
            marca: const MarcaFake(nome: 'Padaria Central'),
          ),
        );

        expect(find.text('Padaria Central'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um nome longo, quando o espaço é pequeno, então o texto fica em uma linha com reticências',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const SizedBox(width: 80, child: MarcaNome()),
            marca: const MarcaFake(
              nome: 'Supermercado Com Nome Muito Comprido',
            ),
          ),
        );

        final texto = tester.widget<Text>(find.byType(Text));
        expect(texto.maxLines, 1);
        expect(texto.overflow, TextOverflow.ellipsis);
      },
    );
  });
}
