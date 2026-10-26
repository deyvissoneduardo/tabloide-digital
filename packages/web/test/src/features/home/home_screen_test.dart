import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: home do painel na web', () {
    late HomeController controller;
    setUp(() => controller = controllerDeTeste());

    Future<void> abrir(WidgetTester tester, Size tela) async {
      tester.view.physicalSize = tela;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(montar(controller: controller));
      await tester.pumpAndSettle();
    }

    group('Cenário: Dado uma tela de desktop (1440×900)', () {
      testWidgets(
        'Então o menu lateral aparece estendido com o nome da marca, sem navegação embaixo',
        (tester) async {
          await abrir(tester, const Size(1440, 900));

          expect(
            tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
            isTrue,
          );
          expect(find.byType(NavigationBar), findsNothing);
          expect(find.text('Tabloide Digital'), findsOneWidget);
        },
      );

      testWidgets(
        'Quando clico em Panfletos, então a seção muda no controller',
        (tester) async {
          await abrir(tester, const Size(1440, 900));

          await tester.tap(
            find.descendant(
              of: find.byType(NavigationRail),
              matching: find.text('Panfletos'),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.secao, SecaoPainel.panfletos);
        },
      );
    });

    group(
      'Cenário: Dado uma tela de tablet em pé (768×1024), classe média',
      () {
        testWidgets(
          'Então o menu lateral aparece recolhido, só com a logo e rótulos sob os ícones',
          (tester) async {
            await abrir(tester, const Size(768, 1024));

            final menu = tester.widget<NavigationRail>(
              find.byType(NavigationRail),
            );
            expect(menu.extended, isFalse);
            expect(menu.labelType, NavigationRailLabelType.all);
            expect(
              find.bySemanticsLabel('Logo de Tabloide Digital'),
              findsOneWidget,
            );
          },
        );
      },
    );

    group('Cenário: Dado o painel web aberto no celular (390×844)', () {
      testWidgets(
        'Então usa o layout do celular: barra superior e navegação embaixo',
        (tester) async {
          await abrir(tester, const Size(390, 844));

          expect(find.byType(NavigationRail), findsNothing);
          expect(find.byType(NavigationBar), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.text('Tabloide Digital'),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets('Quando toco em Filiais, então a seção muda no controller', (
        tester,
      ) async {
        await abrir(tester, const Size(390, 844));

        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Filiais'),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.secao, SecaoPainel.filiais);
      });
    });
  });
}
