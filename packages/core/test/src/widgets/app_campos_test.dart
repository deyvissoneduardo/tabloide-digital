import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

Widget _noFormulario(GlobalKey<FormState> chave, Widget campo) =>
    montarComMarca(
      SizedBox(
        width: 360,
        child: Form(key: chave, child: campo),
      ),
    );

void main() {
  group('Funcionalidade: campo de texto', () {
    testWidgets(
      'Cenário: Dado o campo, então mostra rótulo e ícone, repassa o que é digitado e valida com o validador recebido',
      (tester) async {
        final chave = GlobalKey<FormState>();
        final texto = TextEditingController();
        addTearDown(texto.dispose);
        final digitados = <String>[];
        await tester.pumpWidget(
          _noFormulario(
            chave,
            AppCampoTexto(
              controller: texto,
              rotulo: 'E-mail',
              icone: Icons.email_outlined,
              aoMudar: digitados.add,
              validador: (v) => (v ?? '').isEmpty ? 'Informe o e-mail' : null,
            ),
          ),
        );

        expect(find.text('E-mail'), findsOneWidget);
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
        expect(chave.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('Informe o e-mail'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), 'a@b.com');
        expect(texto.text, 'a@b.com');
        expect(digitados, ['a@b.com']);
      },
    );

    testWidgets(
      'Cenário: Dado um erro vindo de fora (API), então ele aparece no campo mesmo sem validador',
      (tester) async {
        final texto = TextEditingController();
        addTearDown(texto.dispose);
        await tester.pumpWidget(
          _noFormulario(
            GlobalKey<FormState>(),
            AppCampoTexto(
              controller: texto,
              rotulo: 'E-mail',
              icone: Icons.email_outlined,
              erro: 'Este e-mail já está cadastrado.',
            ),
          ),
        );

        expect(find.text('Este e-mail já está cadastrado.'), findsOneWidget);
      },
    );

    testWidgets('Cenário: Dado o campo desabilitado, então não aceita edição', (
      tester,
    ) async {
      final texto = TextEditingController();
      addTearDown(texto.dispose);
      await tester.pumpWidget(
        _noFormulario(
          GlobalKey<FormState>(),
          AppCampoTexto(
            controller: texto,
            rotulo: 'E-mail',
            icone: Icons.email_outlined,
            habilitado: false,
          ),
        ),
      );

      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
        isFalse,
      );
    });
  });

  group('Funcionalidade: campo de senha', () {
    testWidgets(
      'Cenário: Dado a senha oculta, quando toco em "Mostrar senha", então ela aparece e o botão vira "Ocultar senha"',
      (tester) async {
        final texto = TextEditingController();
        addTearDown(texto.dispose);
        await tester.pumpWidget(
          _noFormulario(
            GlobalKey<FormState>(),
            AppCampoSenha(controller: texto, rotulo: 'Senha'),
          ),
        );
        bool oculta() =>
            tester.widget<EditableText>(find.byType(EditableText)).obscureText;

        expect(oculta(), isTrue);
        await tester.tap(find.byTooltip('Mostrar senha'));
        await tester.pump();
        expect(oculta(), isFalse);
        expect(find.byTooltip('Ocultar senha'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um erro da API e o envio pelo teclado, então o erro aparece e o envio chama a ação',
      (tester) async {
        final texto = TextEditingController();
        addTearDown(texto.dispose);
        final enviados = <String>[];
        await tester.pumpWidget(
          _noFormulario(
            GlobalKey<FormState>(),
            AppCampoSenha(
              controller: texto,
              rotulo: 'Senha',
              erro: 'Senha fraca.',
              acao: TextInputAction.done,
              aoEnviar: enviados.add,
            ),
          ),
        );

        expect(find.text('Senha fraca.'), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), 'Teste1234');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        expect(enviados, ['Teste1234']);
      },
    );
  });
}
