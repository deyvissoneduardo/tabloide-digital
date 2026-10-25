import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: campo de seleção', () {
    Widget campo({
      required GlobalKey<FormState> chave,
      required ValueChanged<String?> aoMudar,
      String? valor,
      String? erro,
      bool habilitado = true,
    }) => montarComMarca(
      SizedBox(
        width: 360,
        child: Form(
          key: chave,
          child: AppCampoSelecao<String>(
            valor: valor,
            opcoes: const ['SP', 'RJ'],
            rotuloDe: (uf) => 'UF $uf',
            rotulo: 'UF',
            icone: Icons.map_outlined,
            aoMudar: aoMudar,
            erro: erro,
            habilitado: habilitado,
            validador: (v) => v == null ? 'Escolha a UF.' : null,
          ),
        ),
      ),
    );

    testWidgets(
      'Cenário: Dado o campo vazio, quando valido, então mostra o erro do validador; quando escolho, então repasso a opção',
      (tester) async {
        final chave = GlobalKey<FormState>();
        final escolhas = <String?>[];
        await tester.pumpWidget(campo(chave: chave, aoMudar: escolhas.add));

        expect(chave.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('Escolha a UF.'), findsOneWidget);

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('UF RJ').last);
        await tester.pumpAndSettle();

        expect(escolhas, ['RJ']);
        expect(chave.currentState!.validate(), isTrue);
      },
    );

    testWidgets(
      'Cenário: Dado um erro vindo da API, então ele aparece no campo',
      (tester) async {
        await tester.pumpWidget(
          campo(
            chave: GlobalKey<FormState>(),
            aoMudar: (_) {},
            valor: 'SP',
            erro: 'UF inválida.',
          ),
        );

        expect(find.text('UF SP'), findsOneWidget);
        expect(find.text('UF inválida.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o campo desabilitado, então não abre as opções',
      (tester) async {
        await tester.pumpWidget(
          campo(
            chave: GlobalKey<FormState>(),
            aoMudar: (_) {},
            habilitado: false,
          ),
        );

        final dropdown = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>),
        );
        expect(dropdown.onChanged, isNull);
      },
    );
  });
}
