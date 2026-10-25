import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

final _norte = FilialResponse(
  id: 'norte',
  nome: 'Norte',
  endereco: filialFake.endereco,
  fusoHorario: filialFake.fusoHorario,
  codigoPublico: 'n0rt3',
  urlPublica: 'https://tabloide.app/f/n0rt3',
  criadaEm: filialFake.criadaEm,
  atualizadaEm: filialFake.atualizadaEm,
);

void main() {
  group('Funcionalidade: seção Filiais da home no app', () {
    late FilialRepositoryFake repository;
    late FiliaisController filiais;

    Future<void> abrir(
      WidgetTester tester,
      List<FilialResponse> lista, {
      FilialResponse? emUso,
    }) async {
      repository = FilialRepositoryFake(filiais: lista);
      filiais = filiaisControllerDeTeste(repository: repository);
      await tester.runAsync(filiais.carregar);
      if (emUso != null) filiais.usar(emUso);
      await tester.pumpWidget(
        montarTela(
          const HomeScreen(),
          home: controllerDeTeste()..selecionar(SecaoPainel.filiais),
          filiais: filiais,
          filialRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> acao(WidgetTester tester, String filial, String acao) async {
      await tester.tap(find.byTooltip('Ações da filial $filial'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(acao));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado duas filiais com uma em uso, então lista as duas, marca a em uso e oferece "Nova filial"',
      (tester) async {
        await abrir(tester, [filialFake, filialFakeBairro], emUso: filialFake);

        expect(find.byType(AppCartaoFilial), findsNWidgets(2));
        expect(
          find.descendant(
            of: find.widgetWithText(AppCartaoFilial, 'Centro'),
            matching: find.text('Em uso'),
          ),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(ElevatedButton, 'Nova filial'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado outra filial, quando escolho "Usar esta filial", então ela passa a ser a em uso',
      (tester) async {
        await abrir(tester, [filialFake, filialFakeBairro], emUso: filialFake);

        await acao(tester, 'Bairro Alto', 'Usar esta filial');

        expect(filiais.emUso, filialFakeBairro);
        expect(
          find.text('Agora você está na filial Bairro Alto.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado a seção, quando crio uma filial, então volto para a lista com ela e o aviso de salva',
      (tester) async {
        await abrir(tester, [filialFake]);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Nova filial'));
        await tester.pumpAndSettle();
        expect(find.byType(FilialFormScreen), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome da filial'),
          'Norte',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'CEP'),
          '13010111',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Rua ou avenida'),
          'Rua A',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Número'),
          '1',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Bairro'),
          'Centro',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Cidade'),
          'Campinas',
        );
        await tester.pumpAndSettle();
        final salvar = find.widgetWithText(ElevatedButton, 'Salvar filial');
        await tester.ensureVisible(salvar);
        await tester.tap(salvar);
        await tester.pumpAndSettle();

        expect(find.byType(FilialFormScreen), findsNothing);
        expect(find.text('Filial salva.'), findsOneWidget);
        expect(find.byType(AppCartaoFilial), findsNWidgets(2));
        expect(filiais.emUso, filialFake, reason: 'a nova não troca a em uso');
      },
    );

    testWidgets(
      'Cenário: Dado uma filial, quando escolho "Editar", então o formulário abre preenchido',
      (tester) async {
        await abrir(tester, [filialFake]);

        await acao(tester, 'Centro', 'Editar');

        expect(find.text('Editar filial'), findsOneWidget);
        expect(find.text('Rua das Flores'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a única filial, quando tento excluir, então a opção fica bloqueada e nada é excluído',
      (tester) async {
        await abrir(tester, [filialFake]);

        await acao(tester, 'Centro', 'Excluir (mantenha ao menos uma filial)');

        expect(find.byType(AlertDialog), findsNothing);
        expect(repository.excluidas, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado duas filiais, quando excluo uma e cancelo a confirmação, então nada é excluído',
      (tester) async {
        await abrir(tester, [filialFake, filialFakeBairro], emUso: filialFake);

        await acao(tester, 'Bairro Alto', 'Excluir');
        expect(find.text('Excluir a filial Bairro Alto?'), findsOneWidget);
        expect(
          find.text(
            'Panfleto, categorias e produtos desta filial também serão excluídos.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(repository.excluidas, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado duas filiais, quando confirmo a exclusão de uma, então ela sai da lista e aviso',
      (tester) async {
        await abrir(tester, [filialFake, filialFakeBairro], emUso: filialFake);

        await acao(tester, 'Bairro Alto', 'Excluir');
        await tester.tap(find.widgetWithText(FilledButton, 'Excluir filial'));
        await tester.pumpAndSettle();

        expect(repository.excluidas, [filialFakeBairro.id]);
        expect(find.byType(AppCartaoFilial), findsOneWidget);
        expect(find.text('Filial excluída.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado três filiais, quando excluo a em uso, então o lojista escolhe outra',
      (tester) async {
        await abrir(tester, [
          filialFake,
          filialFakeBairro,
          _norte,
        ], emUso: filialFake);

        await acao(tester, 'Centro', 'Excluir');
        await tester.tap(find.widgetWithText(FilledButton, 'Excluir filial'));
        await tester.pumpAndSettle();

        expect(find.byType(EscolherFilialScreen), findsOneWidget);
        expect(find.byType(HomeScreen, skipOffstage: false), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando a exclusão, quando confirmo, então a filial fica e aviso o erro',
      (tester) async {
        await abrir(tester, [filialFake, filialFakeBairro], emUso: filialFake);
        repository.falhaSimulada = const FalhaSemConexao();

        await acao(tester, 'Bairro Alto', 'Excluir');
        await tester.tap(find.widgetWithText(FilledButton, 'Excluir filial'));
        await tester.pumpAndSettle();

        expect(find.byType(AppCartaoFilial), findsNWidgets(2));
        expect(find.text(const FalhaSemConexao().mensagem), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a lista falhando, então mostra a falha e tenta de novo',
      (tester) async {
        repository = FilialRepositoryFake(
          filiais: [filialFake],
          falhaSimulada: const FalhaSemConexao(),
        );
        filiais = filiaisControllerDeTeste(repository: repository);
        await tester.runAsync(filiais.carregar);
        await tester.pumpWidget(
          montarTela(
            const HomeScreen(),
            home: controllerDeTeste()..selecionar(SecaoPainel.filiais),
            filiais: filiais,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EstadoFalha), findsOneWidget);

        repository.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.byType(AppCartaoFilial), findsOneWidget);
      },
    );
  });
}
