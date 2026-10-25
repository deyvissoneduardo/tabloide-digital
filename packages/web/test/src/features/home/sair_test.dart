import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/testing.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: sair do painel na web', () {
    test('Cenário: Dado uma sessão ativa, quando o service sai, então a sessão e o cache são encerrados', () async {
      final armazenamento = ArmazenamentoMemoria();
      final sessao = sessaoDeTeste(armazenamento: armazenamento);
      await sessao.iniciar(
        token: 'eyJ.token',
        expiraEm: DateTime.utc(2026, 10, 18, 21),
      );

      final resultado = await AuthServiceWeb(
        AuthRepositoryFake(),
        sessao,
      ).sair();

      expect(resultado, const Success<Falha, Nada>(Nada()));
      expect(sessao.ativa, isFalse);
      expect(armazenamento.valores, isEmpty);
    });

    test('Cenário: Dado um login concluído, quando saio, então o login volta a ficar ocioso', () async {
      final controller = loginControllerDeTeste();
      await controller.entrar(email: 'a@b.com', senha: 'Teste1234');

      await controller.sair();

      expect(controller.estado, isA<LoginOcioso>());
      expect(controller.sessao, isNull);
    });

    test('Cenário: Dado filiais carregadas com uma em uso, quando limpo, então não sobra lista nem filial em uso', () async {
      final controller = filiaisControllerDeTeste();
      await controller.carregar();

      controller.limpar();

      expect(controller.estado, isA<FiliaisCarregando>());
      expect(controller.emUso, isNull);
    });

    group('Cenário: Dado a home com uma sessão ativa', () {
      late ArmazenamentoMemoria armazenamento;
      late Sessao sessao;
      late FiliaisController filiais;
      late HomeController home;

      Future<void> abrir(WidgetTester tester, Size tela) async {
        tester.view.physicalSize = tela;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        armazenamento = ArmazenamentoMemoria();
        sessao = sessaoDeTeste(armazenamento: armazenamento);
        await tester.runAsync(
          () => sessao.iniciar(
            token: 'eyJ.token',
            expiraEm: DateTime.utc(2026, 10, 18, 21),
          ),
        );
        filiais = filiaisControllerDeTeste();
        await tester.runAsync(filiais.carregar);
        home = controllerDeTeste()..selecionar(SecaoPainel.filiais);
        await tester.pumpWidget(
          montarTela(
            const HomeScreen(),
            sessao: sessao,
            home: home,
            filiais: filiais,
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> tocarSair(WidgetTester tester) async {
        await tester.tap(find.byTooltip('Sair'));
        await tester.pumpAndSettle();
      }

      testWidgets(
        'Quando toco em Sair e cancelo, então continuo na home com a sessão',
        (tester) async {
          await abrir(tester, const Size(390, 844));

          await tocarSair(tester);
          expect(find.text('Sair do painel?'), findsOneWidget);
          await tester.tap(find.text('Cancelar'));
          await tester.pumpAndSettle();

          expect(find.byType(HomeScreen), findsOneWidget);
          expect(sessao.ativa, isTrue);
        },
      );

      testWidgets(
        'Quando toco em Sair e confirmo, então vou para o login, sem a home na pilha, com sessão, cache e filiais limpos',
        (tester) async {
          await abrir(tester, const Size(390, 844));

          await tocarSair(tester);
          await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
          await tester.pumpAndSettle();

          expect(find.byType(LoginScreen), findsOneWidget);
          expect(find.byType(HomeScreen, skipOffstage: false), findsNothing);
          expect(sessao.ativa, isFalse);
          expect(armazenamento.valores, isEmpty);
          expect(filiais.emUso, isNull);
          expect(home.secao, SecaoPainel.inicio);
        },
      );

      testWidgets(
        'Quando a tela é média, então "Sair" fica no rodapé do menu lateral',
        (tester) async {
          await abrir(tester, const Size(768, 1024));

          expect(
            find.descendant(
              of: find.byType(NavigationRail),
              matching: find.byTooltip('Sair'),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Quando a tela é expandida, então "Sair" aparece com rótulo no menu lateral e funciona',
        (tester) async {
          await abrir(tester, const Size(1440, 900));

          await tester.tap(
            find.descendant(
              of: find.byType(NavigationRail),
              matching: find.text('Sair'),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
          await tester.pumpAndSettle();

          expect(find.byType(LoginScreen), findsOneWidget);
        },
      );
    });
  });
}
