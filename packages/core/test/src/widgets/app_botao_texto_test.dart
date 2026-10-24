import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: botão de texto', () {
    testWidgets(
      'Cenário: Dado o botão, quando toco, então a ação roda e o texto usa a primária',
      (tester) async {
        var toques = 0;
        await tester.pumpWidget(
          montarComMarca(
            AppBotaoTexto(rotulo: 'Cadastre-se', aoPressionar: () => toques++),
          ),
        );

        await tester.tap(find.text('Cadastre-se'));

        expect(toques, 1);
        final contexto = tester.element(find.text('Cadastre-se'));
        expect(
          tester.widget<Text>(find.text('Cadastre-se')).style?.color,
          Theme.of(contexto).colorScheme.primary,
        );
      },
    );

    testWidgets('Cenário: Dado o botão sem ação, então fica desabilitado', (
      tester,
    ) async {
      await tester.pumpWidget(
        montarComMarca(
          const AppBotaoTexto(rotulo: 'Cadastre-se', aoPressionar: null),
        ),
      );

      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
    });
  });
}
