import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

class _ComponentesProduto extends StatelessWidget {
  const _ComponentesProduto();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    children: [
      AppCartaoCategoria(categoria: categoriaFake, aoEscolherAcao: (_) {}),
      AppCartaoCategoria(categoria: categoriaFakeVazia, aoEscolherAcao: (_) {}),
      const SizedBox(height: AppEspacamentos.md),
      AppCartaoProduto(produto: produtoFake, aoEscolherAcao: (_) {}),
      AppCartaoProduto(produto: produtoFakeAgendado, aoEscolherAcao: (_) {}),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoImagem(
        rotulo: 'Foto do produto (opcional)',
        descricao: 'Foto do produto',
        url: 'https://midia.fake/produto/arroz.webp',
        proporcao: 1,
        aoEscolher: () {},
        aoRemover: () {},
        ajuda: 'JPEG, PNG ou WebP de até 10 MB.',
      ),
    ],
  );
}

void main() {
  goldenTest(
    'Cenário: Dado os componentes de categoria e produto, então cartões e foto seguem o tema',
    fileName: 'produto_componentes',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Categorias, produtos vigente e agendado, foto com remover',
          constraints: const BoxConstraints.tightFor(width: 360, height: 900),
          child: montarComMarca(
            const SizedBox.expand(child: _ComponentesProduto()),
          ),
        ),
      ],
    ),
  );
}
