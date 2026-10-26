import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

PanfletoFormController _semImagem() =>
    panfletoFormControllerDeTeste()..salvar(filialId: filialFake.id);

const _telas = {'desktop': Size(1440, 900), 'celular': Size(390, 844)};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado a seção Panfletos da web em $tela, então lista e estado vazio seguem a marca',
      fileName: 'secao_panfletos_web_$tela',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
            for (final (estado, panfletos) in [
              ('vigente e agendado', [panfletoFake, panfletoFakeAgendado]),
              ('vazia', <PanfletoResponse>[]),
            ])
              GoldenTestScenario(
                name: 'Marca $nome, $estado',
                constraints: BoxConstraints.tight(tamanho),
                child: MediaQuery(
                  data: MediaQueryData(size: tamanho),
                  child: montarTela(
                    const HomeScreen(),
                    marca: marca,
                    home: controllerDeTeste()
                      ..selecionar(SecaoPainel.panfletos),
                    filiais: filiaisControllerDeTeste()..carregar(),
                    panfletoRepository: PanfletoRepositoryFake(
                      panfletos: panfletos,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  goldenTest(
    'Cenário: Dado o formulário de panfleto da web, então novo (com erro de imagem) e edição de vigente seguem a marca',
    fileName: 'panfleto_form_screen_web_light',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
          for (final (estado, tela, controller) in [
            (
              'novo sem imagem',
              PanfletoFormScreen(filialId: filialFake.id),
              _semImagem,
            ),
            (
              'edição de vigente',
              PanfletoFormScreen(
                filialId: filialFake.id,
                panfleto: panfletoFake,
              ),
              panfletoFormControllerDeTeste,
            ),
          ])
            GoldenTestScenario(
              name: 'Marca $nome, $estado',
              constraints: const BoxConstraints.tightFor(
                width: 360,
                height: 900,
              ),
              child: montarTela(tela, marca: marca, panfletoForm: controller()),
            ),
      ],
    ),
  );
}
