import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

Widget _cartao({
  SituacaoPaginaFilial situacao = SituacaoPaginaFilial.produtos,
  int produtosNoAr = 12,
  bool contaAtiva = true,
  bool comQr = true,
  bool qrCodeFalhou = false,
  VoidCallback? aoAbrir,
  VoidCallback? aoCopiar,
  VoidCallback? aoCompartilhar,
}) => montarComMarca(
  SingleChildScrollView(
    child: AppCartaoPaginaFilial(
      nomeFilial: 'Centro',
      urlPublica: 'https://tabloide.app/f/k7Qm2xPa',
      situacao: situacao,
      produtosNoAr: produtosNoAr,
      contaAtiva: contaAtiva,
      qrCode: comQr ? pngQrCodeFake : null,
      qrCodeFalhou: qrCodeFalhou,
      aoAbrir: aoAbrir ?? () {},
      aoCopiar: aoCopiar ?? () {},
      aoCompartilhar: aoCompartilhar ?? () {},
    ),
  ),
);

void main() {
  group('Funcionalidade: Card da página da filial (RN35)', () {
    testWidgets('Cenário: Dado situacao panfleto, então "No ar: panfleto"', (
      tester,
    ) async {
      await tester.pumpWidget(_cartao(situacao: SituacaoPaginaFilial.panfleto));

      expect(find.text('No ar: panfleto'), findsOneWidget);
    });

    testWidgets(
      'Cenário: Dado situacao produtos com 12, então "No ar: 12 produtos"',
      (tester) async {
        await tester.pumpWidget(_cartao());

        expect(find.text('No ar: 12 produtos'), findsOneWidget);
      },
    );

    testWidgets('Cenário: Dado situacao vazia, então "Nada no ar"', (
      tester,
    ) async {
      await tester.pumpWidget(_cartao(situacao: SituacaoPaginaFilial.vazia));

      expect(find.text('Nada no ar'), findsOneWidget);
    });

    testWidgets(
      'Cenário: Dado contaAtiva false, então aparece o aviso de página fora do ar e o link continua visível',
      (tester) async {
        await tester.pumpWidget(_cartao(contaAtiva: false));

        expect(
          find.text('Sua página está fora do ar até a conta ser ativada.'),
          findsOneWidget,
        );
        expect(find.text('https://tabloide.app/f/k7Qm2xPa'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado qrCode null, então Esqueleto; dado qrCodeFalhou, então "QR Code indisponível"',
      (tester) async {
        await tester.pumpWidget(_cartao(comQr: false));
        expect(find.byType(Esqueleto), findsOneWidget);

        await tester.pumpWidget(_cartao(comQr: false, qrCodeFalhou: true));
        expect(find.byType(Esqueleto), findsNothing);
        expect(find.text('QR Code indisponível'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado os 3 botões, quando toco em cada um, então o callback certo é chamado',
      (tester) async {
        final chamados = <String>[];
        await tester.pumpWidget(
          _cartao(
            aoAbrir: () => chamados.add('abrir'),
            aoCopiar: () => chamados.add('copiar'),
            aoCompartilhar: () => chamados.add('compartilhar'),
          ),
        );

        for (final rotulo in [
          'Abrir página',
          'Copiar link',
          'Compartilhar link',
        ]) {
          await tester.ensureVisible(find.text(rotulo));
          await tester.tap(find.text(rotulo));
        }

        expect(chamados, ['abrir', 'copiar', 'compartilhar']);
      },
    );

    testWidgets(
      'Cenário: Dado o QR Code, então o semanticLabel cita a filial',
      (tester) async {
        await tester.pumpWidget(_cartao());

        expect(
          find.bySemanticsLabel('QR Code da página da filial Centro'),
          findsOneWidget,
        );
      },
    );
  });
}
