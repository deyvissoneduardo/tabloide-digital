import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

Finder _nome() => find.widgetWithText(TextFormField, 'Nome da categoria');

void main() {
  group('Funcionalidade: formulário de categoria no app', () {
    late CategoriaRepositoryFake repository;

    Future<void> abrir(WidgetTester tester) async {
      repository = CategoriaRepositoryFake(categorias: [categoriaFake]);
      await tester.pumpWidget(
        montarTela(
          CategoriaFormScreen(filialId: filialFake.id),
          categoriaRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> salvar(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar categoria'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado o nome vazio, quando salvo, então peço o nome no campo e nada é enviado',
      (tester) async {
        await abrir(tester);

        await salvar(tester);

        expect(find.text('Informe o nome da categoria.'), findsOneWidget);
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado um nome que já existe, quando salvo, então o erro aparece no campo (RN43) e some ao digitar',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_nome(), 'MERCEARIA');
        await salvar(tester);

        expect(
          find.text('Já existe uma categoria com esse nome nesta filial.'),
          findsOneWidget,
        );
        expect(find.byType(SnackBar), findsNothing);

        await tester.enterText(_nome(), 'Mercearia fina');
        await tester.pump();

        expect(
          find.text('Já existe uma categoria com esse nome nesta filial.'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Cenário: Dado falha de conexão, quando salvo, então aviso o erro e continuo na tela',
      (tester) async {
        await abrir(tester);
        repository.falhaSimulada = const FalhaSemConexao();

        await tester.enterText(_nome(), 'Padaria');
        await salvar(tester);

        expect(
          find.text('Sem conexão. Verifique a internet e tente de novo.'),
          findsOneWidget,
        );
        expect(find.byType(CategoriaFormScreen), findsOneWidget);
      },
    );
  });
}
