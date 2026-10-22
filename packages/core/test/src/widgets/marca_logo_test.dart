import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

final _pngTransparente1x1 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  group('Funcionalidade: logo da marca', () {
    group('Cenário: Dado a marca "Mercado Bom Preço" com logo válida', () {
      final marca = MarcaFake(
        nome: 'Mercado Bom Preço',
        logo: MemoryImage(_pngTransparente1x1),
      );

      testWidgets(
        'Quando a logo aparece, então tem texto alternativo com o nome (RNF10)',
        (tester) async {
          await tester.pumpWidget(
            montarComMarca(const MarcaLogo(), marca: marca),
          );

          expect(
            find.bySemanticsLabel('Logo de Mercado Bom Preço'),
            findsOneWidget,
          );
        },
      );

      testWidgets('Quando informo a altura, então a imagem usa essa altura', (
        tester,
      ) async {
        await tester.pumpWidget(
          montarComMarca(const MarcaLogo(altura: 48), marca: marca),
        );

        expect(tester.widget<Image>(find.byType(Image)).height, 48);
      });
    });

    group('Cenário: Dado a marca "Mercado Bom Preço" com logo quebrada', () {
      const marca = MarcaFake(nome: 'Mercado Bom Preço', logo: LogoIniciais());

      testWidgets(
        'Quando a logo falha, então mostro as iniciais "MB" mantendo o texto alternativo',
        (tester) async {
          await tester.pumpWidget(
            montarComMarca(const MarcaLogo(), marca: marca),
          );
          await tester.pumpAndSettle();

          expect(find.text('MB'), findsOneWidget);
          expect(
            find.bySemanticsLabel('Logo de Mercado Bom Preço'),
            findsOneWidget,
          );
        },
      );
    });
  });
}
