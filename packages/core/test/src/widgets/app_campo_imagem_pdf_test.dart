import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: Campo de imagem do panfleto com PDF', () {
    testWidgets(
      'Cenário: Dado nomePdf, quando desenho, então aparece o ícone de PDF e o nome, e não há Image',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Imagem ou PDF do panfleto',
              descricao: 'Imagem do panfleto',
              url: 'https://midia.fake/panfleto/antigo.webp',
              nomePdf: 'ofertas.pdf',
              aoEscolher: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
        expect(find.text('ofertas.pdf'), findsOneWidget);
        expect(find.text('PDF de 1 página'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(
          find.bySemanticsLabel('PDF escolhido: ofertas.pdf'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado aoEscolherPdf, quando toco em "Escolher PDF", então o callback é chamado',
      (tester) async {
        var toques = 0;
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Imagem ou PDF do panfleto',
              descricao: 'Imagem do panfleto',
              aoEscolher: () {},
              aoEscolherPdf: () => toques++,
            ),
          ),
        );

        await tester.tap(find.text('Escolher PDF'));

        expect(toques, 1);
      },
    );

    testWidgets(
      'Cenário: Dado sem aoEscolherPdf, quando desenho, então o botão "Escolher PDF" não aparece (produto e logo não mudam)',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Foto do produto',
              descricao: 'Foto do produto',
              aoEscolher: () {},
            ),
          ),
        );

        expect(find.text('Escolher PDF'), findsNothing);
        expect(find.text('Escolher imagem'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado erro, quando desenho o estado PDF, então a borda e o texto de erro aparecem',
      (tester) async {
        const mensagem = 'O PDF do panfleto precisa ter só 1 página.';
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Imagem ou PDF do panfleto',
              descricao: 'Imagem do panfleto',
              nomePdf: 'ofertas.pdf',
              erro: mensagem,
              aoEscolher: () {},
            ),
          ),
        );

        expect(find.text(mensagem), findsOneWidget);
        final erro = Theme.of(tester.element(find.text(mensagem)))
            .colorScheme
            .error;
        final quadro = tester.widget<Container>(
          find
              .ancestor(
                of: find.text('ofertas.pdf'),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          ((quadro.decoration! as BoxDecoration).border! as Border).top.color,
          erro,
        );
      },
    );
  });

  group('Funcionalidade: Cartão de panfleto em PDF', () {
    testWidgets(
      'Cenário: Dado panfleto PDF, quando desenho, então não há Image.network e o semanticLabel cita PDF',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(AppCartaoPanfleto(panfleto: panfletoFakePdf)),
        );

        expect(find.byType(Image), findsNothing);
        expect(
          find.bySemanticsLabel(
            RegExp('Panfleto em PDF vigente de 18/10/2026'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
