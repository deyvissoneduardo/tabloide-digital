import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';
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

const _telas = {
  'desktop': Size(1440, 900),
  'tablet': Size(768, 1024),
  'celular': Size(390, 844),
};

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado o cadastro web em $tela, então o formulário segue a largura e a marca e mostra os erros da API nos campos',
      fileName: 'cadastro_screen_web_$tela',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
            for (final (estado, controller) in [
              ('inicial', cadastroControllerDeTeste),
              ('erros da API', _comErrosDaApi),
            ])
              GoldenTestScenario(
                name: 'Marca $nome, $estado',
                constraints: BoxConstraints.tight(tamanho),
                child: MediaQuery(
                  data: MediaQueryData(size: tamanho),
                  child: montarCadastro(marca: marca, controller: controller()),
                ),
              ),
        ],
      ),
    );
  }
}
