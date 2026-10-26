import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _telas = {'desktop': Size(1440, 900), 'celular': Size(390, 844)};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado a seção Produtos da web em $tela, então lista agrupada e estado vazio seguem a marca',
      fileName: 'secao_produtos_web_$tela',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
            for (final (estado, produtos) in [
              ('vigente e agendado', [produtoFake, produtoFakeAgendado]),
              ('vazia', <ProdutoResponse>[]),
            ])
              GoldenTestScenario(
                name: 'Marca $nome, $estado',
                constraints: BoxConstraints.tight(tamanho),
                child: MediaQuery(
                  data: MediaQueryData(size: tamanho),
                  child: montarTela(
                    const HomeScreen(),
                    marca: marca,
                    home: controllerDeTeste()..selecionar(SecaoPainel.produtos),
                    filiais: filiaisControllerDeTeste()..carregar(),
                    produtoRepository: ProdutoRepositoryFake(
                      produtos: produtos,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  goldenTest(
    'Cenário: Dado o formulário de produto da web, então novo e edição de vigente seguem a marca',
    fileName: 'produto_form_screen_web_light',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
          for (final (estado, produto) in [
            ('novo', null),
            ('edição de vigente', produtoFake),
          ])
            GoldenTestScenario(
              name: 'Marca $nome, $estado',
              constraints: const BoxConstraints.tightFor(
                width: 360,
                height: 1500,
              ),
              child: montarTela(
                ProdutoFormScreen(filialId: filialFake.id, produto: produto),
                marca: marca,
                categorias: categoriasControllerDeTeste()
                  ..carregar(filialFake.id),
              ),
            ),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado a tela de categorias da web, então a lista segue a marca',
    fileName: 'categorias_screen_web_light',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
          GoldenTestScenario(
            name: 'Marca $nome',
            constraints: const BoxConstraints.tightFor(width: 360, height: 640),
            child: montarTela(
              CategoriasScreen(filialId: filialFake.id),
              marca: marca,
            ),
          ),
      ],
    ),
  );
}
