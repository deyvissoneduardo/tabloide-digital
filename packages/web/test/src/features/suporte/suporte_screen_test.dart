import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: suporte na web', () {
    Future<void> abrirHome(WidgetTester tester, Size tela) async {
      tester.view.physicalSize = tela;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(montar(controller: controllerDeTeste()));
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      }
    }

    testWidgets(
      'Cenário: Dado uma tela de desktop, quando clico em Suporte no menu lateral, então abre o guia',
      (tester) async {
        await abrirHome(tester, const Size(1440, 900));

        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Suporte'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SuporteScreen), findsOneWidget);
        expect(find.text('1. ${guiaSuporte.first.titulo}'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um tablet (768×1024), quando toco no ícone Suporte do menu lateral, então abre o guia',
      (tester) async {
        await abrirHome(tester, const Size(768, 1024));

        await tester.tap(find.byTooltip('Suporte'));
        await tester.pumpAndSettle();

        expect(find.byType(SuporteScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um celular (390×844), quando toco em Suporte na barra superior, então abre o guia com todos os tópicos',
      (tester) async {
        await abrirHome(tester, const Size(390, 844));

        await tester.tap(find.byTooltip('Suporte'));
        await tester.pumpAndSettle();

        expect(find.byType(SuporteScreen), findsOneWidget);
        for (final (i, topico) in guiaSuporte.indexed) {
          await tester.scrollUntilVisible(
            find.text('${i + 1}. ${topico.titulo}'),
            AppEspacamentos.xl,
          );
          expect(find.text('${i + 1}. ${topico.titulo}'), findsOneWidget);
        }
      },
    );
  });
}
