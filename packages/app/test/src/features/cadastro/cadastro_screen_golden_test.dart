import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

CadastroController _comErrosDaApi() =>
    cadastroControllerDeTeste(
      repository: CadastroRepositoryFake(
        falhaSimulada: const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'email': ['Este e-mail já está cadastrado.'],
            'whatsapp': ['Informe um WhatsApp válido com DDD.'],
            'senha': [
              'A senha precisa ter de 8 a 128 caracteres, com ao menos uma letra e um número.',
            ],
          },
        ),
      ),
    )..cadastrar(
      nomeFantasia: 'Mercado Bom Preço',
      nomeResponsavel: 'Teste 02',
      email: 'teste01@gmail.com',
      senha: 'curta',
      whatsapp: '123',
      cnpj: '11222333000181',
    );

void main() {
  goldenTest(
    'Cenário: Dado o cadastro do app no tema claro, então o formulário segue a marca e mostra os erros da API nos campos',
    fileName: 'cadastro_screen_app_light',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final (estado, controller) in [
          ('inicial', cadastroControllerDeTeste),
          ('erros da API', _comErrosDaApi),
        ])
          GoldenTestScenario(
            name: estado,
            constraints: const BoxConstraints.tightFor(width: 360, height: 900),
            child: montarCadastro(controller: controller()),
          ),
      ],
    ),
  );
}
