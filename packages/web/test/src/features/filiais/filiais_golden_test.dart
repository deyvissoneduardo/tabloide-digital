import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/testing.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

FilialFormController _comErrosDaApi() =>
    filialFormControllerDeTeste(
      repository: FilialRepositoryFake(
        falhaSimulada: const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'endereco.cep': ['CEP inválido.'],
            'fusoHorario': ['Fuso horário inválido.'],
          },
        ),
      ),
    )..salvar(
      nome: 'Centro',
      cep: '13010-111',
      logradouro: 'Rua das Flores',
      numero: '120',
      complemento: '',
      bairro: 'Centro',
      cidade: 'Campinas',
      uf: 'SP',
    );

void main() {
  goldenTest(
    'Cenário: Dado o cadastro de filial da web, então o formulário segue a marca e mostra os erros da API nos campos',
    fileName: 'filial_form_screen_web_light',
    builder: () => GoldenTestGroup(
      columns: 3,
      children: [
        for (final (estado, tela, controller) in [
          (
            'primeira filial',
            const FilialFormScreen(obrigatoria: true),
            filialFormControllerDeTeste,
          ),
          (
            'edição',
            FilialFormScreen(filial: filialFake),
            filialFormControllerDeTeste,
          ),
          ('erros da API', const FilialFormScreen(), _comErrosDaApi),
        ])
          GoldenTestScenario(
            name: estado,
            constraints: const BoxConstraints.tightFor(
              width: 360,
              height: 1000,
            ),
            child: montarTela(tela, filialForm: controller()),
          ),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado mais de uma filial, então a escolha de filial lista os cartões na marca',
    fileName: 'escolher_filial_screen_web_light',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Tema claro',
          constraints: const BoxConstraints.tightFor(width: 360, height: 640),
          child: montarTela(
            const EscolherFilialScreen(),
            filiais: filiaisControllerDeTeste(
              repository: FilialRepositoryFake(
                filiais: [filialFake, filialFakeBairro],
              ),
            )..carregar(),
          ),
        ),
      ],
    ),
  );
}
