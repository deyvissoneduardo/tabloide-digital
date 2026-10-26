import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _semLogo = IdentidadeResponse(
  nomeFantasia: 'Mercado Bom Preço',
  corPrimaria: '#C8102E',
  corSecundaria: '#FFD100',
);

void main() {
  goldenTest(
    'Cenário: Dado o perfil da web, então os dados da loja vêm antes da identidade visual, seguindo a marca, com o botão de sair',
    fileName: 'perfil_screen_web_light',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Tema claro',
          constraints: const BoxConstraints.tightFor(width: 360, height: 1300),
          child: montarTela(
            const PerfilScreen(),
            perfil: perfilControllerDeTeste(
              identidade: IdentidadeRepositoryFake(identidade: _semLogo),
            ),
          ),
        ),
      ],
    ),
  );
}
