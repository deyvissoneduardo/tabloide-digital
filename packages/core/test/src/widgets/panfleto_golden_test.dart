import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

class _ComponentesPanfleto extends StatelessWidget {
  const _ComponentesPanfleto();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    children: [
      AppCartaoPanfleto(panfleto: panfletoFake, aoEscolherAcao: (_) {}),
      AppCartaoPanfleto(panfleto: panfletoFakeAgendado, aoEscolherAcao: (_) {}),
      AppCartaoPanfleto(panfleto: panfletoFakePdf, aoEscolherAcao: (_) {}),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoImagem(
        rotulo: 'Imagem do panfleto',
        descricao: 'Imagem do panfleto',
        aoEscolher: () {},
        erro: 'Escolha a imagem do panfleto.',
        ajuda: 'JPEG, PNG ou WebP de até 10 MB.',
      ),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoImagem(
        rotulo: 'Imagem ou PDF do panfleto',
        descricao: 'Imagem do panfleto',
        nomePdf: 'ofertas-da-semana.pdf',
        aoEscolher: () {},
        aoEscolherPdf: () {},
        ajuda: 'JPEG, PNG ou WebP até 10 MB, ou PDF de 1 página até 2 MB.',
      ),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoData(
        rotulo: 'Data de início',
        valor: DateTime(2026, 10, 18),
        primeiraData: DateTime(2026, 10, 18),
        ultimaData: DateTime(2027, 12, 31),
        aoMudar: (_) {},
        habilitado: false,
        dica: 'Panfleto vigente: a data de início não muda mais.',
      ),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoData(
        rotulo: 'Data limite (opcional)',
        valor: DateTime(2026, 10, 31),
        primeiraData: DateTime(2026, 10, 18),
        ultimaData: DateTime(2027, 12, 31),
        aoMudar: (_) {},
        aoLimpar: () {},
      ),
    ],
  );
}

void main() {
  goldenTest(
    'Cenário: Dado os componentes de panfleto, então cartões (imagem e PDF), campo de imagem, campo com PDF e datas seguem o tema',
    fileName: 'panfleto_componentes',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name:
              'Vigente, agendado, PDF, imagem com erro, campo com PDF e datas',
          constraints: const BoxConstraints.tightFor(width: 360, height: 1500),
          child: montarComMarca(
            const SizedBox.expand(child: _ComponentesPanfleto()),
          ),
        ),
      ],
    ),
  );
}
