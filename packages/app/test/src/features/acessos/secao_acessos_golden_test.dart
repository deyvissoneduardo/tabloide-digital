import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _tamanho = Size(360, 2800);

void main() {
  goldenTest(
    'Cenário: Dado a seção Início com acessos no app, então o painel fica em uma coluna e segue o tema',
    fileName: 'home_inicio_acessos_app',
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
            constraints: BoxConstraints.tight(_tamanho),
            child: MediaQuery(
              data: const MediaQueryData(size: _tamanho),
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
