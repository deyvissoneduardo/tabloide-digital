import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

PanfletoFormController _semImagem() =>
    panfletoFormControllerDeTeste()..salvar(filialId: filialFake.id);

PanfletoFormController _comPdf() =>
    panfletoFormControllerDeTeste()
      ..escolherArquivo(Uint8List(1024), 'ofertas-da-semana.pdf');

const _telas = {'desktop': Size(1440, 900), 'celular': Size(390, 844)};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado a seção Panfletos da web em $tela, então lista e estado vazio seguem a marca',
      fileName: 'secao_panfletos_web_$tela',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          for (final (estado, panfletos) in [
            ('vigente e agendado', [panfletoFake, panfletoFakeAgendado]),
            ('vazia', <PanfletoResponse>[]),
          ])
            GoldenTestScenario(
              name: estado,
              constraints: BoxConstraints.tight(tamanho),
              child: MediaQuery(
                data: MediaQueryData(size: tamanho),
                child: montarTela(
                  const HomeScreen(),
                  home: controllerDeTeste()..selecionar(SecaoPainel.panfletos),
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
    'Cenário: Dado o formulário de panfleto da web, então novo (com erro de imagem), novo com PDF, edição de vigente e edição de PDF seguem a marca',
    fileName: 'panfleto_form_screen_web_light',
    builder: () => GoldenTestGroup(
      columns: 4,
      children: [
        for (final (estado, tela, controller) in [
          (
            'novo sem imagem',
            PanfletoFormScreen(filialId: filialFake.id),
            _semImagem,
          ),
          (
            'novo com PDF',
            PanfletoFormScreen(filialId: filialFake.id),
            _comPdf,
          ),
          (
            'edição de vigente',
            PanfletoFormScreen(filialId: filialFake.id, panfleto: panfletoFake),
            panfletoFormControllerDeTeste,
          ),
          (
            'edição de PDF',
            PanfletoFormScreen(
              filialId: filialFake.id,
              panfleto: panfletoFakePdf,
            ),
            panfletoFormControllerDeTeste,
          ),
        ])
          GoldenTestScenario(
            name: estado,
            constraints: const BoxConstraints.tightFor(width: 360, height: 900),
            child: montarTela(tela, panfletoForm: controller()),
          ),
      ],
    ),
  );
}
