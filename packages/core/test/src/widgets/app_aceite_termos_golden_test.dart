import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

const _mensagem = 'Aceite os Termos de Uso e a Política de Privacidade.';

void main() {
  goldenTest(
    'Cenário: Dado o tema claro, então o AppAceiteTermos segue o tema, com e sem erro',
    fileName: 'app_aceite_termos',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Desmarcado',
          constraints: const BoxConstraints.tightFor(width: 360, height: 80),
          child: montarComMarca(
            AppAceiteTermos(
              aoMudar: (_) {},
              aoAbrirTermos: () {},
              aoAbrirPrivacidade: () {},
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'Marcado',
          constraints: const BoxConstraints.tightFor(width: 360, height: 80),
          child: montarComMarca(
            AppAceiteTermos(
              valorInicial: true,
              aoMudar: (_) {},
              aoAbrirTermos: () {},
              aoAbrirPrivacidade: () {},
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'Com erro',
          constraints: const BoxConstraints.tightFor(width: 360, height: 100),
          child: montarComMarca(
            AppAceiteTermos(
              erro: _mensagem,
              aoMudar: (_) {},
              aoAbrirTermos: () {},
              aoAbrirPrivacidade: () {},
            ),
          ),
        ),
      ],
    ),
  );
}
