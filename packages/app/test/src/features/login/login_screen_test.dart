import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

final _email = find.widgetWithText(TextFormField, 'E-mail');
final _senha = find.widgetWithText(TextFormField, 'Senha');
final _entrar = find.widgetWithText(FilledButton, 'Entrar');

void main() {
  group('Funcionalidade: tela de login no app', () {
    late AuthRepositoryFake repository;

    Future<void> abrir(WidgetTester tester, {AuthRepositoryFake? fake}) {
      repository = fake ?? AuthRepositoryFake();
      return tester.pumpWidget(
        montarLogin(
          marca: const MarcaFake(nome: 'Mercado Bom Preço'),
          controller: loginControllerDeTeste(repository: repository),
        ),
      );
    }

    Future<void> preencher(
      WidgetTester tester,
      String email,
      String senha,
    ) async {
      await tester.enterText(_email, email);
      await tester.enterText(_senha, senha);
      await tester.tap(_entrar);
      await tester.pump();
    }

    testWidgets(
      'Cenário: Dado a tela aberta, então mostra marca, campos, "Entrar" e o apoio de senha (RN36)',
      (tester) async {
        await abrir(tester);

        expect(find.text('Mercado Bom Preço'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Logo de Mercado Bom Preço'),
          findsOneWidget,
        );
        expect(_email, findsOneWidget);
        expect(_senha, findsOneWidget);
        expect(_entrar, findsOneWidget);
        expect(
          find.text('Esqueceu a senha? Fale com o suporte.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado os campos vazios, quando toco em "Entrar", então o erro aparece em cada campo e nada é enviado',
      (tester) async {
        await abrir(tester);

        await preencher(tester, '', '');

        expect(find.text('Informe o e-mail'), findsOneWidget);
        expect(find.text('Informe a senha'), findsOneWidget);
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado um e-mail inválido, quando toco em "Entrar", então o campo diz o que fazer',
      (tester) async {
        await abrir(tester);

        await preencher(tester, 'ana@', 'Teste1234');

        expect(
          find.text('Digite um e-mail válido, como nome@loja.com.br'),
          findsOneWidget,
        );
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado credenciais válidas, quando entro, então envio e-mail e senha e vou para a home',
      (tester) async {
        await abrir(tester);

        await preencher(tester, 'teste01@gmail.com', 'Teste1234');
        await tester.pumpAndSettle();

        expect(repository.pedidos, [
          const LoginRequest(email: 'teste01@gmail.com', senha: 'Teste1234'),
        ]);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando (401), quando entro, então fico no login com o aviso de erro da API',
      (tester) async {
        await abrir(
          tester,
          fake: AuthRepositoryFake(
            falhaSimulada: const FalhaApi(
              codigo: 'CREDENCIAIS_INVALIDAS',
              mensagem: 'E-mail ou senha incorretos.',
            ),
          ),
        );

        await preencher(tester, 'teste01@gmail.com', 'errada');
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('E-mail ou senha incorretos.'),
          ),
          findsOneWidget,
        );
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o login em andamento, então o botão fica desabilitado com spinner e os campos bloqueados',
      (tester) async {
        await abrir(
          tester,
          fake: AuthRepositoryFake(atraso: const Duration(seconds: 1)),
        );

        await preencher(tester, 'teste01@gmail.com', 'Teste1234');

        final botao = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(botao.onPressed, isNull);
        expect(
          find.descendant(
            of: find.byType(FilledButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        expect(tester.widget<TextFormField>(_email).enabled, isFalse);

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(repository.pedidos, hasLength(1));
      },
    );

    testWidgets(
      'Cenário: Dado a senha oculta, quando toco em "Mostrar senha", então ela aparece',
      (tester) async {
        await abrir(tester);
        bool oculta() => tester
            .widget<EditableText>(
              find.descendant(of: _senha, matching: find.byType(EditableText)),
            )
            .obscureText;

        expect(oculta(), isTrue);
        await tester.tap(find.byTooltip('Mostrar senha'));
        await tester.pump();
        expect(oculta(), isFalse);
      },
    );
  });
}
