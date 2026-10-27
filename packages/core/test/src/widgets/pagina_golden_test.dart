import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

const _identidade = IdentidadeResponse(
  nomeFantasia: 'Mercado Bom Preço',
  corPrimaria: '#C8102E',
  corSecundaria: '#FFD100',
);

const _identidadePanfleto = IdentidadeResponse(
  nomeFantasia: 'Mercado Bom Preço',
  corPrimaria: '#C8102E',
  corSecundaria: '#FFD100',
  sePanfleto: true,
);

class _Previa extends StatelessWidget {
  const _Previa(this.dados);

  final DadosPagina dados;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppEspacamentos.sm),
    child: AppPreviaPagina(
      dados: dados,
      categorias: dados.estrutura.categorias,
      aoAbrirPdf: () {},
    ),
  );
}

class _Editor extends StatelessWidget {
  const _Editor({required this.habilitado});

  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final categorias = [
      ...estruturaFake.categorias,
      const CategoriaEstruturaResponse(
        id: 'c-bebidas',
        nome: 'Bebidas',
        produtos: [],
      ),
    ];
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(AppEspacamentos.md),
      buildDefaultDragHandles: false,
      itemCount: categorias.length,
      onReorderItem: (_, _) {},
      itemBuilder: (_, i) => AppEditorCategoria(
        key: ValueKey(categorias[i].id),
        categoria: categorias[i],
        indice: i,
        habilitado: habilitado,
        aoMoverProduto: (_, _) {},
      ),
    );
  }
}

GoldenTestScenario _cenario(String nome, Widget filho, {double altura = 900}) =>
    GoldenTestScenario(
      name: nome,
      constraints: BoxConstraints.tightFor(width: 360, height: altura),
      child: montarComMarca(SizedBox.expand(child: filho)),
    );

void main() {
  goldenTest(
    'Cenário: Dado a prévia da página, então estrutura, panfleto imagem, panfleto PDF e vazio seguem as cores do lojista',
    fileName: 'pagina_previa',
    builder: () => GoldenTestGroup(
      columns: 4,
      children: [
        _cenario(
          'Estrutura',
          _Previa(
            DadosPagina(identidade: _identidade, estrutura: estruturaFake),
          ),
        ),
        _cenario(
          'Panfleto imagem',
          _Previa(
            DadosPagina(
              identidade: _identidadePanfleto,
              estrutura: estruturaFake,
              panfletoVigente: panfletoFake,
            ),
          ),
        ),
        _cenario(
          'Panfleto PDF',
          _Previa(
            DadosPagina(
              identidade: _identidadePanfleto,
              estrutura: estruturaFake,
              panfletoVigente: panfletoFakePdf,
            ),
          ),
        ),
        _cenario(
          'Vazio',
          const _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: EstruturaResponse(categorias: []),
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado o editor da página, então categorias e produtos têm alça quando habilitado e nenhuma quando desabilitado',
    fileName: 'pagina_editor',
    builder: () => GoldenTestGroup(
      children: [
        _cenario('Habilitado', const _Editor(habilitado: true)),
        _cenario('Desabilitado', const _Editor(habilitado: false)),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado o card da página da filial, então status, QR Code, aviso RN35 e ações seguem o tema',
    fileName: 'pagina_filial_card',
    pumpBeforeTest: precacheImages,
    builder: () => GoldenTestGroup(
      columns: 4,
      children: [
        for (final (nome, situacao, contaAtiva, qr, falhou) in [
          ('Ativa com QR', SituacaoPaginaFilial.produtos, true, true, false),
          ('Carregando QR', SituacaoPaginaFilial.panfleto, true, false, false),
          ('Conta não ativa', SituacaoPaginaFilial.vazia, false, true, false),
          ('QR com falha', SituacaoPaginaFilial.produtos, true, false, true),
        ])
          _cenario(
            nome,
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppEspacamentos.md),
              child: AppCartaoPaginaFilial(
                nomeFilial: 'Centro',
                urlPublica: 'https://tabloide.app/f/k7Qm2xPa',
                situacao: situacao,
                produtosNoAr: 12,
                contaAtiva: contaAtiva,
                qrCode: qr ? pngQrCodeFake : null,
                qrCodeFalhou: falhou,
                aoAbrir: () {},
                aoCopiar: () {},
                aoCompartilhar: () {},
              ),
            ),
            altura: 560,
          ),
      ],
    ),
  );
}
