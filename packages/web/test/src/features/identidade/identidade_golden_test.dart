import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _semLogo = IdentidadeResponse(
  nomeFantasia: 'Mercado Bom Preço',
  corPrimaria: '#C8102E',
  corSecundaria: '#FFD100',
);

void main() {
  goldenTest(
    'Cenário: Dado a identidade visual da web, então o formulário segue a marca com logo, cores e o botão de sair',
    fileName: 'identidade_screen_web_light',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
          GoldenTestScenario(
            name: 'Marca $nome',
            constraints: const BoxConstraints.tightFor(width: 360, height: 900),
            child: montarTela(
              const IdentidadeScreen(),
              marca: marca,
              identidade: identidadeControllerDeTeste(
                repository: IdentidadeRepositoryFake(identidade: _semLogo),
              ),
            ),
          ),
      ],
    ),
  );
}
