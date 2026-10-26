import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

class _ComponentesIdentidade extends StatefulWidget {
  const _ComponentesIdentidade();

  @override
  State<_ComponentesIdentidade> createState() => _ComponentesIdentidadeState();
}

class _ComponentesIdentidadeState extends State<_ComponentesIdentidade> {
  final _primaria = TextEditingController(text: '#C8102E');
  final _secundaria = TextEditingController();

  @override
  void dispose() {
    _primaria.dispose();
    _secundaria.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    children: [
      const Center(
        child: AppLogoIdentidade(url: null, nome: 'Mercado Bom Preço'),
      ),
      const SizedBox(height: AppEspacamentos.md),
      AppSeletorCor(controller: _primaria, rotulo: 'Cor primária'),
      const SizedBox(height: AppEspacamentos.md),
      AppSeletorCor(
        controller: _secundaria,
        rotulo: 'Cor secundária',
        erro: 'Informe a cor no formato #RRGGBB.',
      ),
    ],
  );
}

void main() {
  goldenTest(
    'Cenário: Dado a identidade visual, então logo e seletores de cor seguem o tema',
    fileName: 'identidade_componentes',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Sem logo, cor preenchida e cor com erro',
          constraints: const BoxConstraints.tightFor(width: 360, height: 360),
          child: montarComMarca(
            const SizedBox.expand(child: _ComponentesIdentidade()),
          ),
        ),
      ],
    ),
  );
}
