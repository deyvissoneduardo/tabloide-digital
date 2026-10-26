import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  goldenTest(
    'Cenário: Dado a seção Produtos do app, então lista agrupada e estado vazio seguem a marca',
    fileName: 'secao_produtos_app_light',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final (estado, produtos) in [
          ('vigente e agendado', [produtoFake, produtoFakeAgendado]),
          ('vazia', <ProdutoResponse>[]),
        ])
          GoldenTestScenario(
            name: estado,
            constraints: const BoxConstraints.tightFor(width: 360, height: 640),
            child: montarTela(
              const HomeScreen(),
              home: controllerDeTeste()..selecionar(SecaoPainel.produtos),
              filiais: filiaisControllerDeTeste()..carregar(),
              produtoRepository: ProdutoRepositoryFake(produtos: produtos),
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado o formulário de produto do app, então novo e edição de vigente seguem a marca',
    fileName: 'produto_form_screen_app_light',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final (estado, produto) in [
          ('novo', null),
          ('edição de vigente', produtoFake),
        ])
          GoldenTestScenario(
            name: estado,
            constraints: const BoxConstraints.tightFor(
              width: 360,
              height: 1500,
            ),
            child: montarTela(
              ProdutoFormScreen(filialId: filialFake.id, produto: produto),
              categorias: categoriasControllerDeTeste()
                ..carregar(filialFake.id),
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado a tela de categorias do app, então a lista segue a marca',
    fileName: 'categorias_screen_app_light',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Tema claro',
          constraints: const BoxConstraints.tightFor(width: 360, height: 640),
          child: montarTela(CategoriasScreen(filialId: filialFake.id)),
        ),
      ],
    ),
  );
}
