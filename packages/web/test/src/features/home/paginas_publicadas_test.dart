import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: Páginas publicadas na home', () {
    late LinkServiceDeTeste link;

    setUp(() => link = LinkServiceDeTeste());

    LinkServiceDeTeste semCompartilhar() =>
        link = LinkServiceDeTeste(navegadorCompartilha: false);

    Future<void> abrir(
      WidgetTester tester, {
      IdentidadeRepository? identidade,
    }) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FilialRepositoryFake(
        filiais: [filialFake, filialFakeBairro],
      );
      final filiais = filiaisControllerDeTeste(repository: repository);
      await tester.runAsync(filiais.carregar);
      await tester.pumpWidget(
        montarTela(
          const HomeScreen(),
          filiais: filiais,
          linkService: link,
          paginasPublicadas: paginasPublicadasControllerDeTeste(
            identidade: identidade,
            filiais: repository,
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      }
    }

    Future<void> tocar(WidgetTester tester, String filial, String botao) async {
      final alvo = find.descendant(
        of: find.widgetWithText(AppCartaoPaginaFilial, filial),
        matching: find.text(botao),
      );
      await tester.ensureVisible(alvo);
      await tester.tap(alvo);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado 2 filiais, quando abro Início, então há 2 cards na ordem das filiais',
      (tester) async {
        await abrir(tester);

        expect(find.text('Suas páginas'), findsOneWidget);
        final cards = find.byType(AppCartaoPaginaFilial);
        expect(cards, findsNWidgets(2));
        expect(
          tester
              .getTopLeft(find.widgetWithText(AppCartaoPaginaFilial, 'Centro'))
              .dy,
          lessThan(
            tester
                .getTopLeft(
                  find.widgetWithText(AppCartaoPaginaFilial, 'Bairro Alto'),
                )
                .dy,
          ),
        );
        expect(find.text('No ar: 48 produtos'), findsOneWidget);
        expect(find.text('Nada no ar'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado "Copiar link", quando toco, então o Clipboard recebe a urlPublica e aparece "Link copiado"',
      (tester) async {
        await abrir(tester);

        await tocar(tester, 'Centro', 'Copiar link');

        expect(link.copiados, [filialFake.urlPublica]);
        expect(find.text('Link copiado'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado "Abrir página", quando toco, então LinkService.abrir recebe a urlPublica',
      (tester) async {
        await abrir(tester);

        await tocar(tester, 'Bairro Alto', 'Abrir página');

        expect(link.abertos, [filialFakeBairro.urlPublica]);
      },
    );

    testWidgets(
      'Cenário (web): Dado navegador com compartilhar, quando toco em "Compartilhar link", então o navegador recebe o texto com a url',
      (tester) async {
        await abrir(tester);

        await tocar(tester, 'Centro', 'Compartilhar link');

        expect(link.compartilhados, [
          'Confira as ofertas de Mercado Bom Preço - Centro: '
              '${filialFake.urlPublica}',
        ]);
        expect(link.copiados, isEmpty);
        expect(find.text('Link copiado'), findsNothing);
      },
    );

    testWidgets(
      'Cenário (web): Dado navegador sem compartilhar, quando toco em "Compartilhar link", então copia e mostra "Link copiado"',
      (tester) async {
        semCompartilhar();
        await abrir(tester);

        await tocar(tester, 'Centro', 'Compartilhar link');

        expect(link.copiados, [filialFake.urlPublica]);
        expect(find.text('Link copiado'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado falha ao carregar identidade, então "Suas páginas" mostra EstadoFalha e os números continuam',
      (tester) async {
        await abrir(
          tester,
          identidade: IdentidadeRepositoryFake(
            falhaSimulada: const FalhaSemConexao(),
          ),
        );

        expect(find.text('Suas páginas'), findsOneWidget);
        expect(find.byType(EstadoFalha), findsOneWidget);
        expect(find.text('Produtos no ar'), findsOneWidget);
        expect(find.byType(AppCartaoPaginaFilial), findsNothing);
      },
    );
  });
}
