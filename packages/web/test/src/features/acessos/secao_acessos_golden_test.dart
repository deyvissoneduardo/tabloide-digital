import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _telas = {
  'desktop': Size(1440, 2000),
  'tablet': Size(768, 2600),
  'celular': Size(390, 2800),
};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado a seção Início com acessos na web em $tela, então o painel segue a largura e o tema',
      fileName: 'home_inicio_acessos_web_$tela',
      pumpBeforeTest: (tester) async {
        await precarregarLogo(tester);
        for (var i = 0; i < 3; i++) {
          await tester.pump(const Duration(milliseconds: 1));
          await tester.pumpAndSettle();
        }
      },
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          for (final (nome, resumo) in [
            ('Muitos acessos', resumoAcessosFake),
            ('Menos de 100 acessos', resumoAcessosPoucosFake),
          ])
            GoldenTestScenario(
              name: nome,
              constraints: BoxConstraints.tight(tamanho),
              child: MediaQuery(
                data: MediaQueryData(size: tamanho),
                child: montarTela(
                  const HomeScreen(),
                  filiais: filiaisControllerDeTeste(
                    repository: FilialRepositoryFake(
                      filiais: [filialFake, filialFakeBairro],
                    ),
                  )..carregar(),
                  acessos: acessosControllerDeTeste(
                    repository: AcessosRepositoryFake(resumo: resumo),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
