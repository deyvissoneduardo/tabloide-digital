import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

const _telas = {
  'desktop': Size(1440, 900),
  'tablet': Size(768, 1024),
  'celular': Size(390, 844),
};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado a home web em $tela, então o layout segue a largura e a marca',
      fileName: 'home_screen_web_$tela',
      pumpBeforeTest: (tester) async {
        await precarregarLogo(tester);
        for (var i = 0; i < 3; i++) {
          await tester.pump(const Duration(milliseconds: 1));
          await tester.pumpAndSettle();
        }
      },
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'Tema claro',
            constraints: BoxConstraints.tight(tamanho),
            child: MediaQuery(
              data: MediaQueryData(size: tamanho),
              child: montar(
                controller: controllerDeTeste()
                  ..selecionar(SecaoPainel.filiais),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
