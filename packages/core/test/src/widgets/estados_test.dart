import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: estados de tela', () {
    testWidgets(
      'Cenário: Dado um estado vazio com ação, quando toco no botão, então a ação roda',
      (tester) async {
        var cadastrou = false;
        await tester.pumpWidget(
          montarComMarca(
            EstadoVazio(
              icone: Icons.storefront,
              titulo: 'Nenhuma filial cadastrada',
              mensagem: 'Cadastre a primeira para gerar o QR Code.',
              rotuloAcao: 'Cadastrar filial',
              aoAgir: () => cadastrou = true,
            ),
          ),
        );

        expect(find.text('Nenhuma filial cadastrada'), findsOneWidget);
        await tester.tap(find.text('Cadastrar filial'));
        expect(cadastrou, isTrue);
      },
    );

    testWidgets(
      'Cenário: Dado um estado de falha, quando toco em "Tentar de novo", então a operação é refeita',
      (tester) async {
        var tentativas = 0;
        await tester.pumpWidget(
          montarComMarca(
            EstadoFalha(
              mensagem: 'Sem conexão',
              aoTentarDeNovo: () => tentativas++,
            ),
          ),
        );

        await tester.tap(find.text('Tentar de novo'));
        expect(tentativas, 1);
      },
    );

    testWidgets(
      'Cenário: Dado uma lista carregando, então vejo 3 esqueletos anunciados como "Carregando"',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(const SizedBox(height: 400, child: EsqueletoLista())),
        );

        expect(find.byType(Esqueleto), findsNWidgets(3));
        expect(find.bySemanticsLabel('Carregando'), findsNWidgets(3));
      },
    );
  });
}
