import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _desativado = FalhaApi(
  codigo: 'LOJISTA_DESATIVADO',
  mensagem:
      'Sua conta está desativada. O painel está disponível só para consulta.',
);

Finder get _chave =>
    find.widgetWithText(SwitchListTile, 'Mostrar só o panfleto na página');

void main() {
  group('Funcionalidade: Chave "mostrar só o panfleto" (RN44)', () {
    late IdentidadeRepositoryFake identidade;

    setUp(() => identidade = IdentidadeRepositoryFake(atraso: Duration.zero));

    Future<void> abrir(WidgetTester tester, {PerfilController? perfil}) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        montarTela(
          const PerfilScreen(),
          perfil:
              perfil ??
              perfilControllerDeTeste(
                lojista: LojistaRepositoryFake(),
                identidade: identidade,
              ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado identidade com sePanfleto false, quando abro o perfil, então o switch aparece desligado',
      (tester) async {
        await abrir(tester);

        expect(tester.widget<SwitchListTile>(_chave).value, isFalse);
        expect(
          find.text(
            'Vale para todas as filiais. Filial sem panfleto vigente mostra os produtos.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado o switch ligado, quando toco em Salvar, então o IdentidadeRequest leva sePanfleto true',
      (tester) async {
        await abrir(tester);

        await tester.tap(_chave);
        await tester.pump();
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(identidade.pedidos.single.sePanfleto, isTrue);
        expect(tester.widget<SwitchListTile>(_chave).value, isTrue);
      },
    );

    testWidgets(
      'Cenário: Dado salvando, quando a tela redesenha, então o switch fica desabilitado',
      (tester) async {
        final lento = IdentidadeRepositoryFake(
          atraso: const Duration(seconds: 1),
        );
        await abrir(
          tester,
          perfil: perfilControllerDeTeste(
            lojista: LojistaRepositoryFake(),
            identidade: lento,
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salvar'));
        await tester.pump();

        expect(tester.widget<SwitchListTile>(_chave).onChanged, isNull);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      },
    );

    testWidgets(
      'Cenário: Dado falha no PATCH da identidade, quando salvo, então o switch mantém o valor escolhido e aparece o aviso de erro',
      (tester) async {
        await abrir(tester);
        identidade.falhaSimulada = _desativado;

        await tester.tap(_chave);
        await tester.pump();
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(tester.widget<SwitchListTile>(_chave).value, isTrue);
        expect(find.text(_desativado.mensagem), findsOneWidget);
      },
    );
  });
}
