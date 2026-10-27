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

class _Confirmar extends StatelessWidget {
  const _Confirmar({required this.aoResponder});

  final ValueChanged<bool> aoResponder;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async => aoResponder(
      await confirmar(
        context,
        titulo: 'Sair do painel?',
        mensagem: 'Você vai precisar entrar de novo.',
        rotuloConfirmar: 'Sair',
      ),
    ),
    child: const Text('Abrir'),
  );
}

class _Descartar extends StatelessWidget {
  const _Descartar({required this.aoResponder});

  final ValueChanged<bool> aoResponder;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async => aoResponder(
      await confirmar(
        context,
        titulo: 'Descartar as mudanças?',
        mensagem: 'A nova ordem ainda não foi publicada.',
        rotuloConfirmar: 'Descartar',
        rotuloCancelar: 'Continuar editando',
      ),
    ),
    child: const Text('Abrir'),
  );
}

void main() {
  group('Funcionalidade: confirmação com rótulo de cancelar próprio', () {
    testWidgets(
      'Cenário: Dado rotuloCancelar, quando toco nele, então o texto aparece no lugar de "Cancelar" e a resposta é false',
      (tester) async {
        bool? resposta;
        await tester.pumpWidget(
          montarComMarca(_Descartar(aoResponder: (r) => resposta = r)),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsNothing);
        await tester.tap(find.text('Continuar editando'));
        await tester.pumpAndSettle();

        expect(resposta, isFalse);
      },
    );
  });

  group('Funcionalidade: confirmação de ação não destrutiva', () {
    for (final (botao, esperado) in [('Sair', true), ('Cancelar', false)]) {
      testWidgets(
        'Cenário: Dado o dialog aberto, quando toco em "$botao", então a resposta é $esperado e o botão segue o tema',
        (tester) async {
          bool? resposta;
          await tester.pumpWidget(
            montarComMarca(_Confirmar(aoResponder: (r) => resposta = r)),
          );
          await tester.tap(find.text('Abrir'));
          await tester.pumpAndSettle();

          expect(find.text('Sair do painel?'), findsOneWidget);
          expect(
            tester
                .widget<FilledButton>(find.widgetWithText(FilledButton, 'Sair'))
                .style,
            isNull,
          );
          await tester.tap(find.text(botao));
          await tester.pumpAndSettle();

          expect(resposta, esperado);
          expect(find.byType(AlertDialog), findsNothing);
        },
      );
    }
  });

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
    Future<void> mostrar(
      WidgetTester tester,
      void Function(BuildContext context) aviso,
    ) async {
      await tester.pumpWidget(
        montarComMarca(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => aviso(context),
              child: const Text('Salvar'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Salvar'));
      await tester.pump();
    }

    for (final tipo in TipoAviso.values) {
      testWidgets(
        'Cenário: Dado um aviso de ${tipo.name}, quando é mostrado, então aparece com título amigável, ícone e borda na cor do status',
        (tester) async {
          await mostrar(
            tester,
            (context) => mostrarAviso(context, 'Produto salvo', tipo: tipo),
          );

          final contexto = tester.element(find.byType(SnackBar));
          final cor = tipo.cor(Theme.of(contexto).colorScheme);
          final snack = tester.widget<SnackBar>(find.byType(SnackBar));
          expect(find.text('Produto salvo'), findsOneWidget);
          expect(find.text(tipo.tituloPadrao), findsOneWidget);
          expect(tester.widget<Icon>(find.byIcon(tipo.icone)).color, cor);
          expect((snack.shape! as RoundedRectangleBorder).side.color, cor);
          expect(snack.action, isNull);
        },
      );
    }

    testWidgets(
      'Cenário: Dado título, ícone, duração e ação próprios, quando mostro, então o aviso usa cada um',
      (tester) async {
        var agiu = false;
        await mostrar(
          tester,
          (context) => mostrarAviso(
            context,
            'Preencha o endereço à mão.',
            tipo: TipoAviso.alerta,
            titulo: 'Não achamos o CEP',
            icone: Icons.location_off_outlined,
            duracao: const Duration(seconds: 8),
            rotuloAcao: 'Entendi',
            aoAgir: () => agiu = true,
          ),
        );

        final snack = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(find.text('Não achamos o CEP'), findsOneWidget);
        expect(find.byIcon(Icons.location_off_outlined), findsOneWidget);
        expect(snack.duration, const Duration(seconds: 8));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Entendi'));
        expect(agiu, isTrue);
      },
    );
  });
}
