import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: campo de imagem', () {
    testWidgets(
      'Cenário: Dado nenhuma imagem, então mostra o espaço vazio e "Escolher imagem"',
      (tester) async {
        var toques = 0;
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Imagem do panfleto',
              descricao: 'Imagem do panfleto',
              aoEscolher: () => toques++,
              ajuda: 'JPEG, PNG ou WebP de até 10 MB.',
            ),
          ),
        );

        expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
        expect(
          find.bySemanticsLabel('Nenhuma imagem escolhida'),
          findsOneWidget,
        );
        expect(find.text('JPEG, PNG ou WebP de até 10 MB.'), findsOneWidget);
        await tester.tap(find.text('Escolher imagem'));

        expect(toques, 1);
      },
    );

    testWidgets(
      'Cenário: Dado bytes escolhidos, então mostra a prévia e oferece "Trocar imagem"',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Imagem do panfleto',
              descricao: 'Prévia do panfleto',
              bytes: Uint8List.fromList([1, 2, 3]),
              aoEscolher: () {},
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
        expect(find.bySemanticsLabel('Prévia do panfleto'), findsOneWidget);
        expect(find.text('Trocar imagem'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o envio em andamento, então o botão fica desabilitado com spinner',
      (tester) async {
        var toques = 0;
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Imagem do panfleto',
              descricao: 'Imagem do panfleto',
              url: 'https://midia.fake/p.webp',
              carregando: true,
              aoEscolher: () => toques++,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.tap(find.text('Enviando imagem'), warnIfMissed: false);

        expect(toques, 0);
      },
    );

    testWidgets('Cenário: Dado um erro, então ele aparece abaixo do campo', (
      tester,
    ) async {
      await tester.pumpWidget(
        montarComMarca(
          const AppCampoImagem(
            rotulo: 'Imagem do panfleto',
            descricao: 'Imagem do panfleto',
            erro: 'Escolha a imagem do panfleto.',
          ),
        ),
      );

      expect(find.text('Escolha a imagem do panfleto.'), findsOneWidget);
    });

    testWidgets(
      'Cenário: Dado uma imagem salva e a ação de remover, quando toco "Remover imagem", então repasso a ação',
      (tester) async {
        var remocoes = 0;
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Foto do produto',
              descricao: 'Foto do produto',
              url: 'https://midia.fake/produto/arroz.webp',
              aoEscolher: () {},
              aoRemover: () => remocoes++,
            ),
          ),
        );

        await tester.tap(find.text('Remover imagem'));

        expect(remocoes, 1);
      },
    );

    testWidgets(
      'Cenário: Dado nenhuma imagem, então "Remover imagem" não aparece mesmo com a ação',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            AppCampoImagem(
              rotulo: 'Foto do produto',
              descricao: 'Foto do produto',
              aoEscolher: () {},
              aoRemover: () {},
            ),
          ),
        );

        expect(find.text('Remover imagem'), findsNothing);
      },
    );
  });
}
