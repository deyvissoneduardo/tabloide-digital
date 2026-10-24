import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

class _Excluir extends StatelessWidget {
  const _Excluir({required this.aoResponder});

  final ValueChanged<bool> aoResponder;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async => aoResponder(
      await confirmarExclusao(
        context,
        titulo: 'Excluir filial?',
        mensagem: 'Panfleto, categorias e produtos também serão excluídos.',
        rotuloConfirmar: 'Excluir filial',
      ),
    ),
    child: const Text('Abrir'),
  );
}

void main() {
  group('Funcionalidade: confirmação de exclusão (RN12, RN20)', () {
    for (final (botao, esperado) in [
      ('Excluir filial', true),
      ('Cancelar', false),
    ]) {
      testWidgets(
        'Cenário: Dado o dialog aberto, quando toco em "$botao", então a resposta é $esperado',
        (tester) async {
          bool? resposta;
          await tester.pumpWidget(
            montarComMarca(_Excluir(aoResponder: (r) => resposta = r)),
          );
          await tester.tap(find.text('Abrir'));
          await tester.pumpAndSettle();

          expect(
            find.text(
              'Panfleto, categorias e produtos também serão excluídos.',
            ),
            findsOneWidget,
          );
          await tester.tap(find.text(botao));
          await tester.pumpAndSettle();

          expect(resposta, esperado);
          expect(find.byType(AlertDialog), findsNothing);
        },
      );
    }

    testWidgets(
      'Cenário: Dado o dialog aberto, então o botão de confirmar usa a cor de erro',
      (tester) async {
        await tester.pumpWidget(montarComMarca(_Excluir(aoResponder: (_) {})));
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        final botao = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Excluir filial'),
        );
        expect(botao.style!.backgroundColor!.resolve({}), AppCores.erro);
      },
    );
  });

  group('Funcionalidade: aviso de retorno de ação', () {
    for (final tipo in TipoAviso.values) {
      testWidgets(
        'Cenário: Dado um aviso de ${tipo.name}, quando é mostrado, então aparece em SnackBar',
        (tester) async {
          await tester.pumpWidget(
            montarComMarca(
              Builder(
                builder: (context) => TextButton(
                  onPressed: () =>
                      mostrarAviso(context, 'Produto salvo', tipo: tipo),
                  child: const Text('Salvar'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Salvar'));
          await tester.pump();

          final snack = tester.widget<SnackBar>(find.byType(SnackBar));
          expect(find.text('Produto salvo'), findsOneWidget);
          expect(
            snack.backgroundColor,
            tipo == TipoAviso.erro ? AppCores.erro : isNull,
          );
        },
      );
    }
  });
}
