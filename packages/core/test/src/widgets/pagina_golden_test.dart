import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

const _identidade = IdentidadeResponse(nomeFantasia: 'Mercado Bom Preço');

const _identidadePanfleto = IdentidadeResponse(
  nomeFantasia: 'Mercado Bom Preço',
  sePanfleto: true,
);

/// Cores do lojista usadas exatamente (U13): a secundária #FFD100 não é mais
/// escurecida.
const _coresLojista = ConfiguracaoPaginaResponse(
  cores: CoresPaginaResponse(primaria: '#C8102E', secundaria: '#FFD100'),
);

/// 10 cores distintas (E8).
const _coresDistintas = CoresPaginaResponse(
  primaria: '#C8102E',
  secundaria: '#7B1FA2',
  texto: '#112233',
  textoSuave: '#00796B',
  fundoCartao: '#FFF8E1',
  fundoPagina: '#E8F5E9',
  neutra: '#FFCCBC',
  sobreCor: '#FFEB3B',
  fundoBanner: '#0B3D91',
  categoria: '#0B8043',
);

const _bannerCompleto = BannerResponse(
  exibir: true,
  nome: 'Semana do Hortifrúti',
  urlLogo: 'https://midia.fake/logo/banner.webp',
);

class _Previa extends StatelessWidget {
  const _Previa(this.dados, {this.bytesLogoBanner, this.bytesFotoBanner});

  final DadosPagina dados;

  final Uint8List? bytesLogoBanner;

  final Uint8List? bytesFotoBanner;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppEspacamentos.sm),
    child: AppPreviaPagina(
      dados: dados,
      categorias: dados.estrutura.categorias,
      bytesLogoBanner: bytesLogoBanner,
      bytesFotoBanner: bytesFotoBanner,
      aoAbrirPdf: () {},
    ),
  );
}

class _Campanha extends StatefulWidget {
  const _Campanha(this.tipo, {this.bytes, this.erro});

  final TipoCampanha tipo;

  final Uint8List? bytes;

  final String? erro;

  @override
  State<_Campanha> createState() => _CampanhaState();
}

class _CampanhaState extends State<_Campanha> {
  final _descricao = TextEditingController(
    text: 'Frutas e verduras fresquinhas a semana toda.',
  );

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    child: AppCampoCampanha(
      tipo: widget.tipo,
      descricao: _descricao,
      bytesFoto: widget.bytes,
      erroFoto: widget.erro,
      aoMudarTipo: (_) {},
      aoEscolherFoto: () {},
      aoRemoverFoto: () {},
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

/// Decodifica só as imagens locais (logo e foto do banner ainda não
/// publicados); as de rede caem no `errorBuilder`, como antes.
Future<void> _precarregarMemoria(WidgetTester tester) async {
  await tester.runAsync(
    () => Future.wait([
      for (final elemento in find.byType(Image).evaluate())
        if ((elemento.widget as Image).image case final MemoryImage imagem)
          precacheImage(imagem, elemento),
    ]),
  );
  await tester.pumpAndSettle();
}

GoldenTestScenario _cenario(String nome, Widget filho, {double altura = 900}) =>
    GoldenTestScenario(
      name: nome,
      constraints: BoxConstraints.tightFor(width: 360, height: altura),
      child: montarComMarca(SizedBox.expand(child: filho)),
    );

void main() {
  goldenTest(
    'Cenário: Dado a prévia da página (referência visual do React), então cabeçalho, banner, grade, panfleto, vazio e as 10 cores seguem o plano.md §4.4 e §4.6',
    fileName: 'pagina_previa',
    pumpBeforeTest: _precarregarMemoria,
    builder: () => GoldenTestGroup(
      columns: 4,
      children: [
        _cenario(
          'Cabeçalho padrão',
          _Previa(
            DadosPagina(identidade: _identidade, estrutura: estruturaFake),
          ),
        ),
        _cenario(
          'Cores do lojista exatas',
          _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: estruturaFake,
              configuracao: _coresLojista,
            ),
          ),
        ),
        _cenario(
          'Banner com foto',
          _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: estruturaFake,
              configuracao: _coresLojista.copiar(banner: _bannerCompleto),
            ),
            bytesLogoBanner: pngQrCodeFake,
            bytesFotoBanner: pngQrCodeFake,
          ),
        ),
        _cenario(
          'Banner com descrição',
          _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: estruturaFake,
              configuracao: const ConfiguracaoPaginaResponse(
                banner: BannerResponse(
                  exibir: true,
                  nome: 'Semana do Hortifrúti',
                  campanha: CampanhaDescricao(
                    'Frutas e verduras fresquinhas a semana toda. '
                    'Aproveite!',
                  ),
                ),
              ),
            ),
          ),
        ),
        _cenario(
          'Banner vazio',
          _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: estruturaFake,
              configuracao: const ConfiguracaoPaginaResponse(
                banner: BannerResponse(exibir: true),
                cores: CoresPaginaResponse(fundoBanner: '#0B3D91'),
              ),
            ),
          ),
        ),
        _cenario(
          'Grade sem nome de categoria',
          _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: estruturaFake,
              configuracao: const ConfiguracaoPaginaResponse(
                exibirNomeCategoria: false,
              ),
            ),
          ),
        ),
        _cenario(
          '10 cores distintas',
          _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: estruturaFake,
              configuracao: const ConfiguracaoPaginaResponse(
                cores: _coresDistintas,
              ),
            ),
          ),
        ),
        _cenario(
          '10 cores com banner',
          _Previa(
            DadosPagina(
              identidade: _identidade,
              estrutura: estruturaFake,
              configuracao: const ConfiguracaoPaginaResponse(
                banner: BannerResponse(
                  exibir: true,
                  nome: 'Semana do Hortifrúti',
                  campanha: CampanhaDescricao('Tudo fresquinho.'),
                ),
                exibirNomeCategoria: false,
                cores: _coresDistintas,
              ),
            ),
          ),
        ),
        _cenario(
          'Panfleto imagem (banner ligado)',
          _Previa(
            DadosPagina(
              identidade: _identidadePanfleto,
              estrutura: estruturaFake,
              panfletoVigente: panfletoFake,
              configuracao: _coresLojista.copiar(banner: _bannerCompleto),
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
              configuracao: _coresLojista,
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
    'Cenário: Dado o campo de campanha do banner, então Foto (vazia e com erro), Descrição e Nenhuma seguem o tema',
    fileName: 'pagina_campanha',
    pumpBeforeTest: precacheImages,
    builder: () => GoldenTestGroup(
      columns: 4,
      children: [
        _cenario('Foto vazia', const _Campanha(TipoCampanha.foto), altura: 560),
        _cenario(
          'Foto com erro',
          _Campanha(
            TipoCampanha.foto,
            bytes: pngQrCodeFake,
            erro: 'A imagem passa de 10 MB. Escolha uma menor.',
          ),
          altura: 560,
        ),
        _cenario(
          'Descrição',
          const _Campanha(TipoCampanha.descricao),
          altura: 560,
        ),
        _cenario('Nenhuma', const _Campanha(TipoCampanha.nenhuma), altura: 560),
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
