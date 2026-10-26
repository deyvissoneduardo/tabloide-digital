import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

class _ImagePickerMock extends Mock implements ImagePicker {}

PanfletoResponse _semLimite() => PanfletoResponse(
  id: panfletoFake.id,
  filialId: panfletoFake.filialId,
  urlImagem: panfletoFake.urlImagem,
  largura: panfletoFake.largura,
  altura: panfletoFake.altura,
  vigencia: Vigencia(
    dataInicio: panfletoFake.vigencia.dataInicio,
    situacao: SituacaoVigencia.vigente,
    editavel: true,
  ),
  criadoEm: panfletoFake.criadoEm,
);

void main() {
  setUpAll(() => registerFallbackValue(ImageSource.gallery));

  group('Funcionalidade: seção Panfletos da home no app', () {
    late PanfletoRepositoryFake repository;
    late _ImagePickerMock seletor;

    Future<void> abrir(
      WidgetTester tester,
      List<PanfletoResponse> lista, {
      FiliaisController? filiais,
    }) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      repository = PanfletoRepositoryFake(panfletos: lista);
      seletor = _ImagePickerMock();
      final controllerFiliais = filiais ?? filiaisControllerDeTeste();
      if (filiais == null) await tester.runAsync(controllerFiliais.carregar);
      await tester.pumpWidget(
        montarTela(
          const HomeScreen(),
          home: controllerDeTeste()..selecionar(SecaoPainel.panfletos),
          filiais: controllerFiliais,
          panfletoRepository: repository,
          seletorImagem: seletor,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> acao(WidgetTester tester, String inicio, String acao) async {
      await tester.tap(find.byTooltip('Ações do panfleto de $inicio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(acao));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado um vigente e um agendado, então lista os dois em ordem e oferece "Novo panfleto"',
      (tester) async {
        await abrir(tester, [panfletoFakeAgendado, panfletoFake]);

        final cartoes = tester
            .widgetList<AppCartaoPanfleto>(find.byType(AppCartaoPanfleto))
            .map((c) => c.panfleto);
        expect(cartoes, [panfletoFake, panfletoFakeAgendado]);
        expect(
          find.widgetWithText(ElevatedButton, 'Novo panfleto'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Para agendar o próximo panfleto, defina antes a data limite do atual.',
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Cenário: Dado o vigente sem data limite, então oriento a definir a data antes de agendar (RN17)',
      (tester) async {
        await abrir(tester, [_semLimite()]);

        expect(
          find.text(
            'Para agendar o próximo panfleto, defina antes a data limite do atual.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado nenhum panfleto, então mostra o estado vazio com a ação de publicar',
      (tester) async {
        await abrir(tester, []);

        expect(find.text('Nenhum panfleto na filial Centro'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Novo panfleto'));
        await tester.pumpAndSettle();

        expect(find.byType(PanfletoFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado nenhuma filial em uso, então peço para escolher uma',
      (tester) async {
        final filiais = filiaisControllerDeTeste(
          repository: FilialRepositoryFake(
            filiais: [filialFake, filialFakeBairro],
          ),
        );
        await tester.runAsync(filiais.carregar);

        await abrir(tester, [panfletoFake], filiais: filiais);

        expect(find.text('Escolha uma filial'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado nenhum panfleto, quando publico um com imagem, então volto para a lista com ele e o aviso',
      (tester) async {
        await abrir(tester, []);
        when(
          () => seletor.pickImage(
            source: any(named: 'source'),
            maxWidth: any(named: 'maxWidth'),
            maxHeight: any(named: 'maxHeight'),
          ),
        ).thenAnswer(
          (_) async => XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            name: 'folheto.jpg',
            path: 'folheto.jpg',
          ),
        );

        await tester.tap(find.widgetWithText(FilledButton, 'Novo panfleto'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Publicar panfleto'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PanfletoFormScreen), findsNothing);
        expect(find.text('Panfleto publicado.'), findsOneWidget);
        expect(find.byType(AppCartaoPanfleto), findsOneWidget);
        expect(repository.imagensEnviadas, ['folheto.jpg']);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto, quando escolho "Editar", então o formulário abre com a imagem e as datas',
      (tester) async {
        await abrir(tester, [panfletoFake]);

        await acao(tester, '18/10/2026', 'Editar');

        expect(find.text('Editar panfleto'), findsOneWidget);
        expect(find.text('18/10/2026'), findsOneWidget);
        expect(find.text('31/10/2026'), findsOneWidget);
        expect(find.text('Trocar imagem'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto, quando excluo e cancelo, então nada é excluído',
      (tester) async {
        await abrir(tester, [panfletoFake]);

        await acao(tester, '18/10/2026', 'Excluir');
        expect(find.text('Excluir este panfleto?'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(repository.excluidos, isEmpty);
        expect(find.byType(AppCartaoPanfleto), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto, quando confirmo a exclusão, então ele sai da lista e aviso',
      (tester) async {
        await abrir(tester, [panfletoFake, panfletoFakeAgendado]);

        await acao(tester, '18/10/2026', 'Excluir');
        await tester.tap(find.widgetWithText(FilledButton, 'Excluir panfleto'));
        await tester.pumpAndSettle();

        expect(repository.excluidos, [panfletoFake.id]);
        expect(find.byType(AppCartaoPanfleto), findsOneWidget);
        expect(find.text('Panfleto excluído.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando a exclusão, quando confirmo, então o panfleto fica e aviso o erro',
      (tester) async {
        await abrir(tester, [panfletoFake]);
        repository.falhaSimulada = const FalhaSemConexao();

        await acao(tester, '18/10/2026', 'Excluir');
        await tester.tap(find.widgetWithText(FilledButton, 'Excluir panfleto'));
        await tester.pumpAndSettle();

        expect(find.byType(AppCartaoPanfleto), findsOneWidget);
        expect(find.text(const FalhaSemConexao().mensagem), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a lista falhando, então mostra a falha e tenta de novo',
      (tester) async {
        repository = PanfletoRepositoryFake(
          panfletos: [panfletoFake],
          falhaSimulada: const FalhaSemConexao(),
        );
        final filiais = filiaisControllerDeTeste();
        await tester.runAsync(filiais.carregar);
        await tester.pumpWidget(
          montarTela(
            const HomeScreen(),
            home: controllerDeTeste()..selecionar(SecaoPainel.panfletos),
            filiais: filiais,
            panfletoRepository: repository,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EstadoFalha), findsOneWidget);

        repository.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.byType(AppCartaoPanfleto), findsOneWidget);
      },
    );
  });
}
