import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

const _mensagem = 'Aceite os Termos de Uso e a Política de Privacidade.';

String? _validar(bool? marcado) => marcado ?? false ? null : _mensagem;

void main() {
  group('Funcionalidade: AppAceiteTermos (LGPD)', () {
    late List<bool> mudancas;
    late List<String> abertos;
    late GlobalKey<FormState> formulario;

    Future<void> montar(
      WidgetTester tester, {
      bool habilitado = true,
      String? erro,
    }) {
      mudancas = [];
      abertos = [];
      formulario = GlobalKey<FormState>();
      return tester.pumpWidget(
        montarComMarca(
          Form(
            key: formulario,
            child: AppAceiteTermos(
              habilitado: habilitado,
              erro: erro,
              validador: _validar,
              aoMudar: mudancas.add,
              aoAbrirTermos: () => abertos.add('termos'),
              aoAbrirPrivacidade: () => abertos.add('privacidade'),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'Cenário: Dado desmarcado, quando valido o formulário, então mostra o erro e marca a caixa como erro',
      (tester) async {
        await montar(tester);

        expect(formulario.currentState!.validate(), isFalse);
        await tester.pump();

        expect(find.text(_mensagem), findsOneWidget);
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).isError, isTrue);
      },
    );

    testWidgets(
      'Cenário: Dado desmarcado, quando marco a caixa, então avisa a mudança e o formulário passa',
      (tester) async {
        await montar(tester);

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(mudancas, [true]);
        expect(formulario.currentState!.validate(), isTrue);
      },
    );

    testWidgets(
      'Cenário: Dado o texto, quando toco em cada link, então chama o callback do documento',
      (tester) async {
        await montar(tester);

        await tester.tapOnText(find.textRange.ofSubstring('Termos de Uso'));
        await tester.tapOnText(
          find.textRange.ofSubstring('Política de Privacidade'),
        );

        expect(abertos, ['termos', 'privacidade']);
      },
    );

    testWidgets(
      'Cenário: Dado desabilitado, quando toco na caixa, então nada muda',
      (tester) async {
        await montar(tester, habilitado: false);

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(mudancas, isEmpty);
        expect(
          tester.widget<Checkbox>(find.byType(Checkbox)).onChanged,
          isNull,
        );
      },
    );

    testWidgets(
      'Cenário: Dado um erro vindo da API, então ele aparece sem validar',
      (tester) async {
        await montar(tester, erro: 'Erro da API.');
        await tester.pump();

        expect(find.text('Erro da API.'), findsOneWidget);
      },
    );
  });
}
