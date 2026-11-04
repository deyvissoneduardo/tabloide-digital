import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

void main() {
  group(
    'Funcionalidade: Chave "mostrar só o panfleto" fora do Perfil (RN44)',
    () {
      late IdentidadeRepositoryFake identidade;

      setUp(
        () => identidade = IdentidadeRepositoryFake(
          identidade: const IdentidadeResponse(
            nomeFantasia: 'Mercado Bom Preço',
            sePanfleto: true,
          ),
          atraso: Duration.zero,
        ),
      );

      Future<void> abrir(WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          montarTela(
            const PerfilScreen(),
            perfil: perfilControllerDeTeste(
              lojista: LojistaRepositoryFake(),
              identidade: identidade,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      testWidgets(
        'Cenário: Dado o Perfil aberto, quando procuro a chave, então ela não existe (agora fica na filial)',
        (tester) async {
          await abrir(tester);

          expect(find.byType(SwitchListTile), findsNothing);
          expect(find.text('Mostrar só o panfleto na página'), findsNothing);
        },
      );

      testWidgets(
        'Cenário: Dado a identidade com a chave ligada, quando salvo o Perfil, então o pedido não leva sePanfleto e não mexe nas filiais',
        (tester) async {
          await abrir(tester);

          await tester.tap(find.text('Salvar'));
          await tester.pumpAndSettle();

          expect(identidade.pedidos.single.sePanfleto, isNull);
          expect(
            identidade.pedidos.single.toJson().keys,
            isNot(contains('sePanfleto')),
          );
          expect(identidade.identidade.sePanfleto, isTrue);
        },
      );
    },
  );
}
