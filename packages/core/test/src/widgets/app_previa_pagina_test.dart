import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

const _bebidas = CategoriaEstruturaResponse(
  id: 'c-bebidas',
  nome: 'Bebidas',
  produtos: [],
);

DadosPagina _dados({
  bool sePanfleto = false,
  PanfletoResponse? panfleto,
  String? corPrimaria = '#C8102E',
  ConfiguracaoPaginaResponse? configuracao,
}) => DadosPagina(
  identidade: IdentidadeResponse(
    nomeFantasia: 'Mercado Bom Preço',
    sePanfleto: sePanfleto,
  ),
  estrutura: estruturaFake,
  panfletoVigente: panfleto,
  configuracao:
      configuracao ??
      ConfiguracaoPaginaResponse(
        cores: CoresPaginaResponse(
          primaria: corPrimaria,
          secundaria: '#FFD100',
        ),
      ),
);

Future<void> _desenhar(
  WidgetTester tester,
  DadosPagina dados, {
  List<CategoriaEstruturaResponse>? categorias,
  ConfiguracaoPaginaResponse? configuracao,
  Uint8List? bytesFoto,
  VoidCallback? aoAbrirPdf,
}) async {
  await tester.binding.setSurfaceSize(const Size(420, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    montarComMarca(
      SingleChildScrollView(
        child: AppPreviaPagina(
          dados: dados,
          categorias: categorias ?? dados.estrutura.categorias,
          configuracao: configuracao,
          bytesFotoBanner: bytesFoto,
          aoAbrirPdf: aoAbrirPdf,
        ),
      ),
    ),
  );
}

ConfiguracaoPaginaResponse _comBanner(BannerResponse banner) =>
    ConfiguracaoPaginaResponse(banner: banner);

Color? _corDoTexto(WidgetTester tester, String texto) =>
    tester.widget<Text>(find.text(texto)).style?.color;

String _hex(Color? cor) => AppCoresPagina.paraHex(cor!);

/// Cor da primeira caixa decorada acima de [alvo].
Color? _fundoDe(WidgetTester tester, Finder alvo) {
  for (final elemento
      in find
          .ancestor(of: alvo, matching: find.byType(DecoratedBox))
          .evaluate()) {
    final decoracao = (elemento.widget as DecoratedBox).decoration;
    if (decoracao case BoxDecoration(:final color?)) return color;
  }
  for (final elemento
      in find.ancestor(of: alvo, matching: find.byType(Container)).evaluate()) {
    if ((elemento.widget as Container).decoration case BoxDecoration(
      :final color?,
    )) {
      return color;
    }
  }
  return null;
}

/// 10 cores distintas, todas escolhidas (E8).
const _distintas = CoresPaginaResponse(
  primaria: '#C8102E',
  secundaria: '#7B1FA2',
  texto: '#112233',
  textoSuave: '#445566',
  fundoCartao: '#FFF8E1',
  fundoPagina: '#E8F5E9',
  neutra: '#E0E0E0',
  sobreCor: '#FFFDE7',
  fundoBanner: '#0B3D91',
  categoria: '#0B8043',
);

void main() {
  group('Funcionalidade: Prévia da página (RN29, RN41, RN44)', () {
    testWidgets(
      'Cenário: Dado sePanfleto e panfleto vigente, quando desenho, então só cabeçalho + panfleto',
      (tester) async {
        await _desenhar(
          tester,
          _dados(sePanfleto: true, panfleto: panfletoFake),
        );

        expect(find.text('Mercado Bom Preço'), findsOneWidget);
        expect(find.byType(AppPreviaPanfleto), findsOneWidget);
        expect(find.byType(AppPreviaCategoria), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado sePanfleto sem panfleto vigente, quando desenho, então as categorias',
      (tester) async {
        await _desenhar(tester, _dados(sePanfleto: true));

        expect(find.byType(AppPreviaPanfleto), findsNothing);
        expect(find.text('Hortifrúti'), findsOneWidget);
        expect(find.text('Mercearia'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado sePanfleto false e panfleto vigente, quando desenho, então as categorias e nenhum panfleto',
      (tester) async {
        await _desenhar(tester, _dados(panfleto: panfletoFake));

        expect(find.byType(AppPreviaPanfleto), findsNothing);
        expect(find.byType(AppPreviaCategoria), findsNWidgets(2));
      },
    );

    testWidgets(
      'Cenário: Dado categoria sem produtos, quando desenho, então ela não aparece (RN41)',
      (tester) async {
        final dados = _dados();
        await _desenhar(
          tester,
          dados,
          categorias: [...dados.estrutura.categorias, _bebidas],
        );

        expect(find.text('Bebidas'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado nenhuma categoria com produtos, quando desenho, então "Nenhuma oferta no momento."',
      (tester) async {
        await _desenhar(tester, _dados(), categorias: [_bebidas]);

        expect(find.text('Nenhuma oferta no momento.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a lista em edição em outra ordem, quando desenho, então a ordem segue a lista recebida',
      (tester) async {
        final dados = _dados();
        final [hortifruti, mercearia] = dados.estrutura.categorias;
        await _desenhar(tester, dados, categorias: [mercearia, hortifruti]);

        expect(
          tester.getTopLeft(find.text('Mercearia')).dy,
          lessThan(tester.getTopLeft(find.text('Hortifrúti')).dy),
        );
      },
    );

    testWidgets(
      'Cenário: Dado produto agendado, quando desenho, então não há selo nem diferença de estilo',
      (tester) async {
        await _desenhar(tester, _dados());

        expect(find.textContaining('Agendado'), findsNothing);
        final banana = tester.widget<Text>(find.text('Banana prata'));
        final maca = tester.widget<Text>(find.text('Maçã gala'));
        expect(maca.style, banana.style);
      },
    );

    testWidgets(
      'Cenário: Dado preço original, quando desenho, então aparece "de R\$ X" e o preço promocional',
      (tester) async {
        await _desenhar(tester, _dados());

        expect(find.text('de R\$ 6,99'), findsOneWidget);
        expect(find.text('R\$ 4,99'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('de R\$ 6,99')).style?.decoration,
          TextDecoration.lineThrough,
        );
      },
    );

    testWidgets(
      'Cenário: Dado data limite, quando desenho, então "válido até dd/mm"',
      (tester) async {
        await _desenhar(tester, _dados());

        expect(find.text('válido até 20/11'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado primária #FFD100, quando desenho, então nome e preço do produto usam #FFD100 exato (U13, E9)',
      (tester) async {
        await _desenhar(tester, _dados(corPrimaria: '#FFD100'));

        expect(_hex(_corDoTexto(tester, 'Banana prata')), '#FFD100');
        expect(_hex(_corDoTexto(tester, 'R\$ 4,99')), '#FFD100');
      },
    );

    testWidgets(
      'Cenário: Dado preço original maior, quando desenho, então o selo mostra o desconto arredondado',
      (tester) async {
        await _desenhar(tester, _dados());

        expect(find.text('-29%'), findsOneWidget);
      },
    );

    test('Cenário: Dado preço original ausente, igual ou menor, quando calculo, então sem desconto', () {
      expect(AppPreviaProduto.percentualDesconto(499, 699), 29);
      expect(AppPreviaProduto.percentualDesconto(499, null), isNull);
      expect(AppPreviaProduto.percentualDesconto(499, 499), isNull);
      expect(AppPreviaProduto.percentualDesconto(499, 300), isNull);
      expect(AppPreviaProduto.percentualDesconto(1000, 1001), isNull);
    });

    test('Cenário: Dado nomes de tamanhos diferentes, quando calculo as iniciais, então até 2 letras', () {
      expect(AppPreviaCabecalho.iniciais('Mercado Bom Preço'), 'MP');
      expect(AppPreviaCabecalho.iniciais('  atacadão '), 'A');
      expect(AppPreviaCabecalho.iniciais(''), '');
    });

    testWidgets(
      'Cenário: Dado identidade sem logo, quando desenho, então as iniciais no cabeçalho',
      (tester) async {
        await _desenhar(tester, _dados());

        expect(find.text('MP'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado categorias, quando desenho, então o total de ofertas de cada uma',
      (tester) async {
        final dados = _dados();
        await _desenhar(tester, dados);

        for (final categoria in dados.estrutura.categorias) {
          final total = categoria.produtos.length;
          expect(
            find.text(total == 1 ? '1 oferta' : '$total ofertas'),
            findsWidgets,
          );
        }
      },
    );

    testWidgets(
      'Cenário: Dado panfleto PDF, quando toco em "Abrir PDF", então aoAbrirPdf é chamado',
      (tester) async {
        var aberturas = 0;
        await _desenhar(
          tester,
          _dados(sePanfleto: true, panfleto: panfletoFakePdf),
          aoAbrirPdf: () => aberturas++,
        );

        expect(find.text('0192f0c2.pdf'), findsOneWidget);
        await tester.tap(find.text('Abrir PDF'));

        expect(aberturas, 1);
      },
    );

    testWidgets(
      'Cenário: Dado banner ligado sem panfleto, quando desenho, então o banner substitui o cabeçalho (U3)',
      (tester) async {
        await _desenhar(tester, _dados(configuracao: configuracaoPaginaFake));

        expect(find.byType(AppPreviaBanner), findsOneWidget);
        expect(find.byType(AppPreviaCabecalho), findsNothing);
        expect(find.text('Semana do Hortifrúti'), findsOneWidget);
        expect(find.text('Mercado Bom Preço'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado banner ligado e panfleto em exibição, quando desenho, então cabeçalho + panfleto e nenhum banner (U8)',
      (tester) async {
        await _desenhar(
          tester,
          _dados(
            sePanfleto: true,
            panfleto: panfletoFake,
            configuracao: configuracaoPaginaFake,
          ),
        );

        expect(find.byType(AppPreviaBanner), findsNothing);
        expect(find.byType(AppPreviaCabecalho), findsOneWidget);
        expect(find.byType(AppPreviaPanfleto), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado banner desligado, quando desenho, então o cabeçalho volta (E4)',
      (tester) async {
        await _desenhar(
          tester,
          _dados(),
          configuracao: _comBanner(
            const BannerResponse(nome: 'Semana do Hortifrúti'),
          ),
        );

        expect(find.byType(AppPreviaBanner), findsNothing);
        expect(find.text('Mercado Bom Preço'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado banner sem logo, nome nem campanha, quando desenho, então é só a faixa de cor (E3)',
      (tester) async {
        await _desenhar(
          tester,
          _dados(),
          configuracao: _comBanner(const BannerResponse(exibir: true)),
        );

        final banner = find.byType(AppPreviaBanner);
        expect(banner, findsOneWidget);
        expect(
          find.descendant(of: banner, matching: find.byType(Text)),
          findsNothing,
        );
        expect(
          find.descendant(of: banner, matching: find.byType(Image)),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Cenário: Dado campanha FOTO, quando desenho, então a foto em 16:9 abaixo do nome e sem descrição',
      (tester) async {
        await _desenhar(
          tester,
          _dados(),
          configuracao: _comBanner(
            const BannerResponse(
              exibir: true,
              nome: 'Semana do Hortifrúti',
              campanha: CampanhaFoto('https://midia.fake/banner/foto.webp'),
            ),
          ),
        );

        final foto = find.bySemanticsLabel('Foto da campanha');
        expect(foto, findsOneWidget);
        final proporcao = tester.widget<AspectRatio>(
          find.ancestor(of: foto, matching: find.byType(AspectRatio)).first,
        );
        expect(proporcao.aspectRatio, 16 / 9);
        expect(
          tester.getTopLeft(foto).dy,
          greaterThan(tester.getTopLeft(find.text('Semana do Hortifrúti')).dy),
        );
      },
    );

    testWidgets(
      'Cenário: Dado campanha DESCRICAO, quando desenho, então a descrição na cor sobreCor e sem foto (E2)',
      (tester) async {
        await _desenhar(
          tester,
          _dados(),
          configuracao: const ConfiguracaoPaginaResponse(
            banner: BannerResponse(
              exibir: true,
              campanha: CampanhaDescricao('Tudo fresquinho'),
            ),
            cores: CoresPaginaResponse(sobreCor: '#FFFDE7'),
          ),
        );

        expect(find.text('Tudo fresquinho'), findsOneWidget);
        expect(find.bySemanticsLabel('Foto da campanha'), findsNothing);
        expect(_hex(_corDoTexto(tester, 'Tudo fresquinho')), '#FFFDE7');
      },
    );

    testWidgets(
      'Cenário: Dado foto escolhida e ainda não publicada, quando desenho, então a prévia mostra os bytes locais (T6)',
      (tester) async {
        await _desenhar(
          tester,
          _dados(),
          configuracao: _comBanner(const BannerResponse(exibir: true)),
          bytesFoto: pngQrCodeFake,
        );

        final imagem = tester.widget<Image>(
          find.byWidgetPredicate(
            (w) => w is Image && w.semanticLabel == 'Foto da campanha',
          ),
        );
        expect(imagem.image, isA<MemoryImage>());
      },
    );

    testWidgets(
      'Cenário: Dado nome da categoria desligado, quando desenho, então grade única na ordem e sem título nem contador (U10, E6)',
      (tester) async {
        await _desenhar(
          tester,
          _dados(
            configuracao: const ConfiguracaoPaginaResponse(
              exibirNomeCategoria: false,
            ),
          ),
        );

        expect(find.byType(AppPreviaGradeProdutos), findsOneWidget);
        expect(find.byType(AppPreviaCategoria), findsNothing);
        expect(find.text('Hortifrúti'), findsNothing);
        expect(find.textContaining('oferta'), findsNothing);
        final banana = tester.getTopLeft(find.text('Banana prata'));
        final maca = tester.getTopLeft(find.text('Maçã gala'));
        final arroz = tester.getTopLeft(find.text('Arroz 5 kg'));
        expect(maca.dy, banana.dy, reason: '2 colunas na mesma linha');
        expect(maca.dx, greaterThan(banana.dx));
        expect(arroz.dy, greaterThan(banana.dy));
        expect(arroz.dx, banana.dx);
      },
    );

    testWidgets(
      'Cenário: Dado as 10 cores distintas, quando desenho, então cada elemento usa o token da tabela §4.4 (E8)',
      (tester) async {
        await _desenhar(
          tester,
          _dados(
            configuracao: const ConfiguracaoPaginaResponse(cores: _distintas),
          ),
        );

        expect(_hex(_corDoTexto(tester, 'Banana prata')), '#C8102E');
        expect(_hex(_corDoTexto(tester, 'Hortifrúti')), '#0B8043');
        expect(_hex(_corDoTexto(tester, 'Tipo 1')), '#7B1FA2');
        expect(_hex(_corDoTexto(tester, '-29%')), '#FFFDE7');
        expect(_hex(_fundoDe(tester, find.text('-29%'))), '#7B1FA2');
        expect(_hex(_corDoTexto(tester, '2 ofertas')), '#445566');
        expect(_hex(_corDoTexto(tester, 'de R\$ 6,99')), '#445566');
        expect(_hex(_corDoTexto(tester, 'válido até 20/11')), '#112233');
        expect(
          _hex(_fundoDe(tester, find.text('válido até 20/11'))),
          '#E0E0E0',
        );
        expect(_hex(_fundoDe(tester, find.text('Banana prata'))), '#FFF8E1');
        expect(_hex(_corDoTexto(tester, 'Mercado Bom Preço')), '#FFFDE7');
        expect(
          _hex(_fundoDe(tester, find.text('Mercado Bom Preço'))),
          '#C8102E',
        );
        expect(
          _hex(_fundoDe(tester, find.byType(AppPreviaCabecalho))),
          '#E8F5E9',
        );
      },
    );

    testWidgets(
      'Cenário: Dado as 10 cores e o banner ligado, quando desenho, então o fundo do banner é fundoBanner',
      (tester) async {
        await _desenhar(
          tester,
          _dados(
            configuracao: const ConfiguracaoPaginaResponse(
              banner: BannerResponse(exibir: true, nome: 'Semana'),
              cores: _distintas,
            ),
          ),
        );

        expect(_hex(_fundoDe(tester, find.text('Semana'))), '#0B3D91');
        expect(_hex(_corDoTexto(tester, 'Semana')), '#FFFDE7');
      },
    );

    testWidgets(
      'Cenário: Dado página vazia com cores, quando desenho, então "Nenhuma oferta" em texto sobre fundoCartao',
      (tester) async {
        await _desenhar(
          tester,
          _dados(
            configuracao: const ConfiguracaoPaginaResponse(cores: _distintas),
          ),
          categorias: [_bebidas],
        );

        expect(
          _hex(_corDoTexto(tester, 'Nenhuma oferta no momento.')),
          '#112233',
        );
        expect(
          _hex(_fundoDe(tester, find.text('Nenhuma oferta no momento.'))),
          '#FFF8E1',
        );
      },
    );
  });
}
