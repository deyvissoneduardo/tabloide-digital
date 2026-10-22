import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';

import '../../../helpers/montar.dart';

void main() {
  for (final brilho in Brightness.values) {
    goldenTest(
      'Cenário: Dado a home do app no tema ${brilho.name}, então cada seção segue a marca',
      fileName: 'home_screen_app_${brilho.name}',
      builder: () => GoldenTestGroup(
        columns: SecaoPainel.values.length,
        children: [
          for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
            for (final secao in SecaoPainel.values)
              GoldenTestScenario(
                name: 'Marca $nome, seção ${secao.name}',
                constraints: const BoxConstraints.tightFor(
                  width: 360,
                  height: 800,
                ),
                child: montar(
                  marca: marca,
                  brilho: brilho,
                  controller: controllerDeTeste()..selecionar(secao),
                ),
              ),
        ],
      ),
    );
  }
}
