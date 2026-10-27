import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: Sair da seção Página com mudanças (D11)', () {
    late HomeController home;
    late PaginaController pagina;

    setUp(() {
      home = controllerDeTeste()..selecionar(SecaoPainel.pagina);
      pagina = paginaControllerDeTeste();
    });

    Future<void> abrir(WidgetTester tester, {bool mudar = true}) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final filiais = filiaisControllerDeTeste();
      await tester.runAsync(filiais.carregar);
      await tester.pumpWidget(
        montarTela(
          const HomeScreen(),
          home: home,
          filiais: filiais,
          pagina: pagina,
        ),
      );
      await tester.pumpAndSettle();
      if (mudar) {
        pagina.moverCategoria(0, 1);
        await tester.pump();
      }
    }

    Future<void> tocarInicio(WidgetTester tester) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Início'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado mudanças não publicadas, quando toco em "Início", então aparece "Descartar as mudanças?"',
      (tester) async {
        await abrir(tester);

        await tocarInicio(tester);

        expect(find.text('Descartar as mudanças?'), findsOneWidget);
        expect(
          find.text('A nova ordem ainda não foi publicada.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado o diálogo, quando toco em "Continuar editando", então continuo na seção Página com a ordem editada',
      (tester) async {
        await abrir(tester);
        final editada = pagina.emEdicao;

        await tocarInicio(tester);
        await tester.tap(find.text('Continuar editando'));
        await tester.pumpAndSettle();

        expect(home.secao, SecaoPainel.pagina);
        expect(pagina.emEdicao, editada);
        expect(pagina.temMudancas, isTrue);
      },
    );

    testWidgets(
      'Cenário: Dado o diálogo, quando toco em "Descartar", então vou para Início e a ordem volta à salva',
      (tester) async {
        await abrir(tester);

        await tocarInicio(tester);
        await tester.tap(find.text('Descartar'));
        await tester.pumpAndSettle();

        expect(home.secao, SecaoPainel.inicio);
        expect(pagina.emEdicao, pagina.salvo);
      },
    );

    testWidgets(
      'Cenário: Dado sem mudanças, quando toco em "Início", então troca de seção sem diálogo',
      (tester) async {
        await abrir(tester, mudar: false);

        await tocarInicio(tester);

        expect(find.text('Descartar as mudanças?'), findsNothing);
        expect(home.secao, SecaoPainel.inicio);
      },
    );

    testWidgets(
      'Cenário: Dado mudanças, quando abro o Perfil, então aparece o diálogo',
      (tester) async {
        await abrir(tester);

        await tester.tap(find.byTooltip('Perfil'));
        await tester.pumpAndSettle();

        expect(find.text('Descartar as mudanças?'), findsOneWidget);
        expect(find.byType(PerfilScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado mudanças, quando uso o voltar do Android, então aparece o diálogo e não saio',
      (tester) async {
        await abrir(tester);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('Descartar as mudanças?'), findsOneWidget);
        await tester.tap(find.text('Descartar'));
        await tester.pumpAndSettle();
        expect(pagina.temMudancas, isFalse);
      },
    );
  });
}
