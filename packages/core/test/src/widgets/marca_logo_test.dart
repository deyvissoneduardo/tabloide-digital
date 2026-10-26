import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: logo da marca', () {
    testWidgets(
      'Cenário: Dado o painel, quando a logo aparece, então usa o asset do Tabloide com texto alternativo (RNF10)',
      (tester) async {
        await tester.pumpWidget(montarComMarca(const MarcaLogo()));

        expect(tester.widget<Image>(find.byType(Image)).image, AppMarca.logo);
        expect(
          find.bySemanticsLabel('Logo de Tabloide Digital'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado uma altura, quando a logo aparece, então a imagem usa essa altura',
      (tester) async {
        await tester.pumpWidget(montarComMarca(const MarcaLogo(altura: 48)));

        expect(tester.widget<Image>(find.byType(Image)).height, 48);
      },
    );
  });
}
