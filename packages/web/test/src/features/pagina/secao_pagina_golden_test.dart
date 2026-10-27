import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/testing.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

const _telas = {'desktop': Size(1440, 900), 'celular': Size(390, 844)};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado a seção Página na web em $tela, então ${tela == 'desktop' ? 'editor e prévia ficam lado a lado' : 'há abas "Montar" e "Prévia"'} e "Publicar ordem" segue a marca',
      fileName: 'secao_pagina_web_$tela',
      pumpBeforeTest: (tester) async {
        await precarregarLogo(tester);
        await tester.pumpAndSettle();
      },
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'Tema claro',
            constraints: BoxConstraints.tight(tamanho),
            child: MediaQuery(
              data: MediaQueryData(size: tamanho),
              child: montarTela(
                const HomeScreen(),
                home: controllerDeTeste()..selecionar(SecaoPainel.pagina),
                filiais: filiaisControllerDeTeste()..carregar(),
                pagina: paginaControllerDeTeste(
                  identidade: IdentidadeRepositoryFake(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
