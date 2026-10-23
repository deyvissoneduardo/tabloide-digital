import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';

import '../../../helpers/montar.dart';

void main() {
  goldenTest(
    'Cenário: Dado a home do app no tema claro, então cada seção segue a marca',
    fileName: 'home_screen_app_light',
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
                controller: controllerDeTeste()..selecionar(secao),
              ),
            ),
      ],
    ),
  );
}
