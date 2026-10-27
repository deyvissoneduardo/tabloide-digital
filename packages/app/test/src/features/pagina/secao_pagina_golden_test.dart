import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  goldenTest(
    'Cenário: Dado a seção Página no app (compacto), então "Publicar ordem", as abas e o editor seguem a marca',
    fileName: 'secao_pagina_app_light',
    pumpBeforeTest: (tester) async {
      await precarregarLogo(tester);
      await tester.pumpAndSettle();
    },
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final (nome, identidade) in [
          ('montar', identidadeFake),
          (
            'montar com só panfleto ligado',
            const IdentidadeResponse(
              nomeFantasia: 'Mercado Bom Preço',
              sePanfleto: true,
            ),
          ),
        ])
          GoldenTestScenario(
            name: nome,
            constraints: const BoxConstraints.tightFor(width: 360, height: 800),
            child: montarTela(
              const HomeScreen(),
              home: controllerDeTeste()..selecionar(SecaoPainel.pagina),
              filiais: filiaisControllerDeTeste()..carregar(),
              pagina: paginaControllerDeTeste(
                identidade: IdentidadeRepositoryFake(identidade: identidade),
              ),
            ),
          ),
      ],
    ),
  );
}
