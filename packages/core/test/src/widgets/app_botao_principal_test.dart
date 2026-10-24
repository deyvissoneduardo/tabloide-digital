import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: botão principal', () {
    testWidgets(
      'Cenário: Dado o botão parado, quando toco, então a ação roda e o rótulo usa a cor do tema',
      (tester) async {
        var toques = 0;
        const marca = MarcaFake(corPrimaria: Color(0xFFC62828));
        await tester.pumpWidget(
          montarComMarca(
            AppBotaoPrincipal(rotulo: 'Entrar', aoPressionar: () => toques++),
            marca: marca,
          ),
        );

        await tester.tap(find.text('Entrar'));

        expect(toques, 1);
        final cores = AppTheme.claro(marca).colorScheme;
        final estilo = tester
            .widget<ElevatedButton>(find.byType(ElevatedButton))
            .style!;
        expect(estilo.backgroundColor?.resolve({}), cores.primary);
        expect(
          tester.widget<Text>(find.text('Entrar')).style?.color,
          cores.onPrimary,
        );
      },
    );

    testWidgets(
      'Cenário: Dado o botão carregando, então fica desabilitado com spinner e anuncia o rótulo de carregamento',
      (tester) async {
        var toques = 0;
        await tester.pumpWidget(
          montarComMarca(
            AppBotaoPrincipal(
              rotulo: 'Entrar',
              rotuloCarregando: 'Entrando',
              carregando: true,
              aoPressionar: () => toques++,
            ),
          ),
        );

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        expect(find.text('Entrar'), findsNothing);
        expect(find.bySemanticsLabel('Entrando'), findsOneWidget);
        await tester.tap(find.byType(ElevatedButton));
        expect(toques, 0);
      },
    );
  });
}
