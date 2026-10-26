import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: home do painel no app', () {
    group('Cenário: Dado a home aberta com a marca "Mercado Bom Preço"', () {
      late HomeController controller;
      setUp(() => controller = controllerDeTeste());

      Future<void> abrir(WidgetTester tester) async {
        final filiais = filiaisControllerDeTeste();
        await tester.runAsync(filiais.carregar);
        await tester.pumpWidget(
          montar(
            marca: const MarcaFake(nome: 'Mercado Bom Preço'),
            controller: controller,
            filiais: filiais,
          ),
        );
      }

      testWidgets('Então a barra superior mostra o nome e a logo da marca', (
        tester,
      ) async {
        await abrir(tester);

        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Mercado Bom Preço'),
          ),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Logo de Mercado Bom Preço'),
          findsOneWidget,
        );
      });

      testWidgets(
        'Então a navegação de baixo tem as 4 seções e Início selecionado',
        (tester) async {
          await abrir(tester);

          final barra = tester.widget<NavigationBar>(
            find.byType(NavigationBar),
          );
          expect(barra.destinations, hasLength(SecaoPainel.values.length));
          expect(barra.selectedIndex, SecaoPainel.inicio.index);
        },
      );

      testWidgets(
        'Quando toco em Produtos, então a seção muda no controller e o conteúdo troca',
        (tester) async {
          await abrir(tester);

          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text('Produtos'),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.secao, SecaoPainel.produtos);
          expect(find.byType(SecaoProdutos), findsOneWidget);
        },
      );

      testWidgets('Quando o controller muda de fora, então a tela acompanha', (
        tester,
      ) async {
        await abrir(tester);

        controller.selecionar(SecaoPainel.filiais);
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          SecaoPainel.filiais.index,
        );
      });
    });
  });
}
