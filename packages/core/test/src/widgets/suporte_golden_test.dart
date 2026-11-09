import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

class _ComponentesSuporte extends StatelessWidget {
  const _ComponentesSuporte();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    children: [
      AppTopicoSuporte(
        topico: guiaSuporte[2],
        numero: 3,
        inicialmenteAberto: true,
      ),
      AppTopicoSuporte(topico: guiaSuporte[4], numero: 5),
    ],
  );
}

void main() {
  goldenTest(
    'Cenário: Dado os tópicos do suporte, então o aberto mostra passos e dicas e o fechado só título e resumo',
    fileName: 'suporte_componentes',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Tópico aberto e tópico fechado',
          constraints: const BoxConstraints.tightFor(width: 360, height: 1000),
          child: montarComMarca(
            const SizedBox.expand(child: _ComponentesSuporte()),
          ),
        ),
      ],
    ),
  );
}
