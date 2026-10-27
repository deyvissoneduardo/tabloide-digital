import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';

import '../../../helpers/montar.dart';

void main() {
  goldenTest(
    'Cenário: Dado a home do app no tema claro, então cada seção segue a marca',
    fileName: 'home_screen_app_light',
    pumpBeforeTest: (tester) async {
      await precarregarLogo(tester);
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      }
    },
    builder: () => GoldenTestGroup(
      columns: SecaoPainel.values.length,
      children: [
        for (final secao in SecaoPainel.values)
          GoldenTestScenario(
            name: 'Seção ${secao.name}',
            constraints: const BoxConstraints.tightFor(width: 360, height: 800),
            child: montar(controller: controllerDeTeste()..selecionar(secao)),
          ),
      ],
    ),
  );
}
