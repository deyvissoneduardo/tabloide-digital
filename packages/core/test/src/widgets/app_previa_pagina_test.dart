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
}) => DadosPagina(
  identidade: IdentidadeResponse(
    nomeFantasia: 'Mercado Bom Preço',
    corPrimaria: corPrimaria,
    corSecundaria: '#FFD100',
    sePanfleto: sePanfleto,
  ),
  estrutura: estruturaFake,
  panfletoVigente: panfleto,
);

Future<void> _desenhar(
  WidgetTester tester,
  DadosPagina dados, {
  List<CategoriaEstruturaResponse>? categorias,
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
          aoAbrirPdf: aoAbrirPdf,
        ),
      ),
    ),
  );
}

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
      'Cenário: Dado corPrimaria #FFD100, quando desenho, então o nome do produto usa #8A7100',
      (tester) async {
        await _desenhar(tester, _dados(corPrimaria: '#FFD100'));

        final cor = tester
            .widget<Text>(find.text('Banana prata'))
            .style!
            .color!;
        expect(AppCoresPagina.paraHex(cor), '#8A7100');
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
  });
}
