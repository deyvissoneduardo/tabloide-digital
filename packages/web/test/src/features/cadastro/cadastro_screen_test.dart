import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);
final _cadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');

const _mensagemSenha =
    'A senha precisa ter de 8 a 128 caracteres, com ao menos uma letra e um número.';

void main() {
  group('Funcionalidade: tela de cadastro na web', () {
    late CadastroRepositoryFake repository;

    Future<void> abrir(WidgetTester tester, {CadastroRepositoryFake? fake}) {
      repository = fake ?? CadastroRepositoryFake();
      final sessao = sessaoDeTeste();
      return tester.pumpWidget(
        montarCadastro(
          sessao: sessao,
          controller: cadastroControllerDeTeste(
            repository: repository,
            sessao: sessao,
          ),
        ),
      );
    }

    Future<void> preencher(
      WidgetTester tester, {
      String nomeFantasia = 'Mercado Bom Preço',
      String nomeResponsavel = 'Teste 02',
      String email = 'teste01@gmail.com',
      String whatsapp = '11987654321',
      String cnpj = '11222333000181',
      String senha = 'Teste1234',
      String? confirmarSenha,
    }) async {
      await tester.enterText(_campo('Nome fantasia'), nomeFantasia);
      await tester.enterText(_campo('Nome do responsável'), nomeResponsavel);
      await tester.enterText(_campo('E-mail'), email);
      await tester.enterText(_campo('WhatsApp (com DDD)'), whatsapp);
      await tester.enterText(_campo('CNPJ'), cnpj);
      await tester.enterText(_campo('Senha'), senha);
      await tester.enterText(
        _campo('Confirmar senha'),
        confirmarSenha ?? senha,
      );
    }

    Future<void> enviar(WidgetTester tester) async {
      await tester.ensureVisible(_cadastrar);
      await tester.tap(_cadastrar);
      await tester.pump();
    }

    testWidgets(
      'Cenário: Dado a tela aberta, então mostra o título, os 7 campos na ordem e "Cadastrar"',
      (tester) async {
        await abrir(tester);

        expect(find.text('Crie sua conta'), findsOneWidget);
        final rotulos = [
          'Nome fantasia',
          'Nome do responsável',
          'E-mail',
          'WhatsApp (com DDD)',
          'CNPJ',
          'Senha',
          'Confirmar senha',
        ];
        final posicoes = [
          for (final r in rotulos) tester.getTopLeft(_campo(r)).dy,
        ];
        expect(
          posicoes,
          [...posicoes]..sort(),
          reason: 'campos na ordem pedida',
        );
        expect(_cadastrar, findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado os campos vazios, quando toco em "Cadastrar", então cada campo diz o que falta e nada é enviado',
      (tester) async {
        await abrir(tester);

        await enviar(tester);

        for (final mensagem in [
          'Informe o nome fantasia.',
          'Informe o nome do responsável.',
          'Informe o e-mail.',
          'Informe o WhatsApp.',
          'Informe o CNPJ.',
          'Informe a senha.',
          'Confirme a senha.',
        ]) {
          expect(find.text(mensagem), findsOneWidget, reason: mensagem);
        }
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado nomes com 1 caractere, quando toco em "Cadastrar", então os dois pedem o mínimo de 2',
      (tester) async {
        await abrir(tester);

        await preencher(tester, nomeFantasia: 'M', nomeResponsavel: 'A');
        await enviar(tester);

        expect(find.text('Mínimo de 2 caracteres.'), findsNWidgets(2));
        expect(repository.pedidos, isEmpty);
      },
    );

    for (final (caso, senha) in [
      ('curta', 'abc123'),
      ('sem número', 'abcdefgh'),
      ('sem letra', '12345678'),
      ('com mais de 128', 'a1' * 65),
    ]) {
      testWidgets(
        'Cenário: Dado uma senha $caso, quando toco em "Cadastrar", então o campo explica a regra da API',
        (tester) async {
          await abrir(tester);

          await preencher(tester, senha: senha);
          await enviar(tester);

          expect(find.text(_mensagemSenha), findsOneWidget);
          expect(repository.pedidos, isEmpty);
        },
      );
    }

    testWidgets(
      'Cenário: Dado a confirmação diferente da senha, quando toco em "Cadastrar", então o campo avisa',
      (tester) async {
        await abrir(tester);

        await preencher(tester, confirmarSenha: 'Outra1234');
        await enviar(tester);

        expect(find.text('As senhas não conferem.'), findsOneWidget);
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando com 400, quando cadastro, então cada erro aparece no seu campo e a mensagem geral no aviso',
      (tester) async {
        await abrir(
          tester,
          fake: CadastroRepositoryFake(
            falhaSimulada: const FalhaApi(
              codigo: 'VALIDACAO_INVALIDA',
              mensagem: 'Dados inválidos.',
              campos: {
                'whatsapp': ['Informe um WhatsApp válido com DDD.'],
              },
            ),
          ),
        );

        await preencher(tester, whatsapp: '123');
        await enviar(tester);
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: _campo('WhatsApp (com DDD)'),
            matching: find.text('Informe um WhatsApp válido com DDD.'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Dados inválidos.'),
          ),
          findsOneWidget,
        );

        await tester.enterText(_campo('WhatsApp (com DDD)'), '11987654321');
        await tester.pump();
        expect(
          find.text('Informe um WhatsApp válido com DDD.'),
          findsNothing,
          reason: 'editar o campo tira o erro da API',
        );
      },
    );

    testWidgets(
      'Cenário: Dado um e-mail já cadastrado (409), quando cadastro, então o erro aparece no campo E-mail (RN37)',
      (tester) async {
        const mensagem = 'Este e-mail já está cadastrado.';
        await abrir(
          tester,
          fake: CadastroRepositoryFake(
            falhaSimulada: const FalhaApi(
              codigo: 'EMAIL_JA_CADASTRADO',
              mensagem: mensagem,
              campos: {
                'email': [mensagem],
              },
            ),
          ),
        );

        await preencher(tester);
        await enviar(tester);
        await tester.pumpAndSettle();

        expect(
          find.descendant(of: _campo('E-mail'), matching: find.text(mensagem)),
          findsOneWidget,
        );
        expect(find.byType(CadastroScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o cadastro em andamento, então o botão fica desabilitado com spinner e os campos bloqueados',
      (tester) async {
        await abrir(
          tester,
          fake: CadastroRepositoryFake(atraso: const Duration(seconds: 1)),
        );

        await preencher(tester);
        await enviar(tester);

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        expect(
          find.descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        expect(tester.widget<TextFormField>(_campo('E-mail')).enabled, isFalse);

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(repository.pedidos, hasLength(1));
      },
    );

    testWidgets(
      'Cenário: Dado o login, quando toco em "Cadastre-se", cadastro com sucesso, então vou para a home sem o login na pilha',
      (tester) async {
        repository = CadastroRepositoryFake();
        final sessao = sessaoDeTeste();
        await tester.pumpWidget(
          montarLogin(
            sessao: sessao,
            cadastro: cadastroControllerDeTeste(
              repository: repository,
              sessao: sessao,
            ),
          ),
        );

        await tester.tap(find.widgetWithText(TextButton, 'Cadastre - se '));
        await tester.pumpAndSettle();
        expect(find.byType(CadastroScreen), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);

        await preencher(tester);
        await enviar(tester);
        await tester.pumpAndSettle();

        expect(repository.pedidos, [
          const CadastroRequest(
            nomeFantasia: 'Mercado Bom Preço',
            nomeResponsavel: 'Teste 02',
            email: 'teste01@gmail.com',
            senha: 'Teste1234',
            whatsapp: '11987654321',
            cnpj: '11222333000181',
          ),
        ]);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen, skipOffstage: false), findsNothing);
        expect(find.byType(CadastroScreen, skipOffstage: false), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado um erro da API, quando volto ao login e abro o cadastro de novo, então o erro antigo não aparece',
      (tester) async {
        const mensagem = 'Este e-mail já está cadastrado.';
        await tester.pumpWidget(
          montarLogin(
            cadastro: cadastroControllerDeTeste(
              repository: CadastroRepositoryFake(
                falhaSimulada: const FalhaApi(
                  codigo: 'EMAIL_JA_CADASTRADO',
                  mensagem: mensagem,
                  campos: {
                    'email': [mensagem],
                  },
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.widgetWithText(TextButton, 'Cadastre - se '));
        await tester.pumpAndSettle();
        await preencher(tester);
        await enviar(tester);
        await tester.pumpAndSettle();
        expect(
          find.descendant(of: _campo('E-mail'), matching: find.text(mensagem)),
          findsOneWidget,
        );

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Cadastre - se '));
        await tester.pumpAndSettle();

        expect(
          find.descendant(of: _campo('E-mail'), matching: find.text(mensagem)),
          findsNothing,
        );
      },
    );
  });
}
