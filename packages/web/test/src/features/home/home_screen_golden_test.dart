import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

const _telas = {
  'desktop': Size(1440, 900),
  'tablet': Size(900, 700),
  'celular': Size(390, 844),
};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado a home web em $tela, então o layout segue a largura e a marca',
      fileName: 'home_screen_web_$tela',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
            for (final brilho in Brightness.values)
              GoldenTestScenario(
                name: 'Marca $nome, ${brilho.name}',
                constraints: BoxConstraints.tight(tamanho),
                child: MediaQuery(
                  data: MediaQueryData(size: tamanho),
                  child: montar(
                    marca: marca,
                    brilho: brilho,
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
