import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: seletor de cor', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    testWidgets(
      'Cenário: Dado o campo vazio, quando digito uma cor com letras minúsculas e lixo, então fica #RRGGBB em maiúsculas com no máximo 6 dígitos',
      (tester) async {
        final mudancas = <String>[];
        await tester.pumpWidget(
          montarComMarca(
            AppSeletorCor(
              controller: controller,
              rotulo: 'Cor primária',
              aoMudar: mudancas.add,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'c8-10zz2eff9');

        expect(controller.text, '#C8102E');
        expect(mudancas.last, '#C8102E');
      },
    );

    testWidgets(
      'Cenário: Dado uma cor no campo, quando abro a paleta e confirmo, então o campo recebe a cor escolhida',
      (tester) async {
        controller.text = '#C8102E';
        final mudancas = <String>[];
        await tester.pumpWidget(
          montarComMarca(
            AppSeletorCor(
              controller: controller,
              rotulo: 'Cor primária',
              aoMudar: mudancas.add,
            ),
          ),
        );

        await tester.tap(find.byTooltip('Escolher Cor primária'));
        await tester.pumpAndSettle();
        expect(find.byType(ColorPicker), findsOneWidget);
        tester
            .widget<ColorPicker>(find.byType(ColorPicker))
            .onColorChanged(const Color(0xFF00FF00));
        await tester.pump();
        await tester.tap(find.text('Usar cor'));
        await tester.pumpAndSettle();

        expect(controller.text, '#00FF00');
        expect(mudancas, ['#00FF00']);
      },
    );

    testWidgets(
      'Cenário: Dado a paleta aberta, quando cancelo, então o campo não muda',
      (tester) async {
        controller.text = '#C8102E';
        await tester.pumpWidget(
          montarComMarca(
            AppSeletorCor(controller: controller, rotulo: 'Cor primária'),
          ),
        );

        await tester.tap(find.byTooltip('Escolher Cor primária'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(controller.text, '#C8102E');
      },
    );

    testWidgets(
      'Cenário: Dado o seletor desabilitado, então o botão da paleta fica desabilitado',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppSeletorCor(
              controller: controller,
              rotulo: 'Cor primária',
              habilitado: false,
            ),
          ),
        );

        final botao = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.palette_outlined),
            matching: find.byType(IconButton),
          ),
        );

        expect(botao.onPressed, isNull);
      },
    );

    testWidgets(
      'Cenário: Dado um erro da API, então ele aparece no próprio campo',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppSeletorCor(
              controller: controller,
              rotulo: 'Cor primária',
              erro: 'Informe a cor no formato #RRGGBB.',
            ),
          ),
        );

        expect(find.text('Informe a cor no formato #RRGGBB.'), findsOneWidget);
      },
    );
  });

  group('Funcionalidade: logo da identidade', () {
    testWidgets(
      'Cenário: Dado um lojista sem logo, então mostra o espaço para enviar',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const AppLogoIdentidade(url: null, nome: 'Mercado Bom Preço'),
          ),
        );

        expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
        expect(find.bySemanticsLabel('Sem logo'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado uma URL que não carrega, então mostra o ícone de imagem quebrada',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const AppLogoIdentidade(
              url: 'https://midia.fake/logo.png',
              nome: 'Mercado Bom Preço',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
        expect(
          find.bySemanticsLabel('Logo de Mercado Bom Preço'),
          findsOneWidget,
        );
      },
    );
  });
}
