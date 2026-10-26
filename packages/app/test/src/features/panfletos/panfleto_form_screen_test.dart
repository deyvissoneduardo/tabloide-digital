import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

class _ImagePickerMock extends Mock implements ImagePicker {}

class _PanfletoRepositoryMock extends Mock implements PanfletoRepository {}

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

void main() {
  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(const PanfletoRequest());
  });

  group('Funcionalidade: formulário de panfleto no app', () {
    late PanfletoRepositoryFake repository;
    late _ImagePickerMock seletor;

    setUp(() {
      repository = PanfletoRepositoryFake(panfletos: [panfletoFake]);
      seletor = _ImagePickerMock();
    });

    void escolherImagem(Future<XFile?> Function() resposta) => when(
      () => seletor.pickImage(
        source: any(named: 'source'),
        maxWidth: any(named: 'maxWidth'),
        maxHeight: any(named: 'maxHeight'),
      ),
    ).thenAnswer((_) => resposta());

    Future<void> abrir(
      WidgetTester tester, {
      PanfletoResponse? panfleto,
      PanfletosController? panfletos,
    }) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        montarTela(
          PanfletoFormScreen(filialId: filialFake.id, panfleto: panfleto),
          panfletoRepository: repository,
          panfletos: panfletos,
          seletorImagem: seletor,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> publicar(WidgetTester tester) async {
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Publicar panfleto'),
      );
      await tester.pumpAndSettle();
    }

    XFile imagem([String nome = 'folheto.jpg']) =>
        XFile.fromData(Uint8List.fromList([1, 2, 3]), name: nome, path: nome);

    testWidgets(
      'Cenário: Dado um panfleto novo, então as datas são opcionais e explicam o que acontece sem elas',
      (tester) async {
        await abrir(tester);

        expect(find.text('Novo panfleto'), findsOneWidget);
        expect(
          find.text('Sem data: começa hoje, ao publicar.'),
          findsOneWidget,
        );
        expect(find.text('Sem data: vale até ser excluído.'), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(_campo('Data de início (opcional)'))
              .enabled,
          isTrue,
        );
      },
    );

    testWidgets(
      'Cenário: Dado a data limite, quando abro o calendário, então ele aparece em pt-BR',
      (tester) async {
        await abrir(tester);

        await tester.tap(_campo('Data limite (opcional)'));
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
        expect(
          find.textContaining(
            RegExp(
              'janeiro|fevereiro|março|abril|maio|junho|julho|agosto|'
              'setembro|outubro|novembro|dezembro',
            ),
          ),
          findsWidgets,
        );
        expect(find.text('Cancelar'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado nenhuma imagem, quando publico, então peço a imagem no campo e nada é enviado',
      (tester) async {
        await abrir(tester);

        await publicar(tester);

        expect(find.text('Escolha a imagem do panfleto.'), findsOneWidget);
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado o seletor fechado sem imagem, quando escolho, então nada muda',
      (tester) async {
        escolherImagem(() async => null);
        await abrir(tester);

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();

        expect(find.text('Escolher imagem'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o seletor sem permissão, quando escolho, então aviso o erro',
      (tester) async {
        escolherImagem(() async => throw PlatformException(code: 'negado'));
        await abrir(tester);

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Não conseguimos abrir suas imagens. Verifique a permissão e tente de novo.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado o vigente sem data limite, quando agendo outro, então oriento a definir a data limite do atual (RN17)',
      (tester) async {
        escolherImagem(() async => imagem());
        await abrir(tester);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'PANFLETO_ATUAL_SEM_DATA_LIMITE',
          mensagem: 'Defina uma data limite no panfleto atual antes de agendar o próximo.',
        );

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();
        await publicar(tester);

        expect(find.text('Defina a data limite'), findsOneWidget);
        expect(
          find.text(
            'Defina uma data limite no panfleto atual antes de agendar o próximo.',
          ),
          findsOneWidget,
        );
        expect(find.byType(PanfletoFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um período que se sobrepõe a outro, quando publico, então aviso o conflito com o período do outro e não saio (RN16)',
      (tester) async {
        escolherImagem(() async => imagem());
        await abrir(tester);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'PANFLETO_PERIODO_SOBREPOSTO',
          mensagem: 'Já existe um panfleto nesse período.',
          detalhes: {
            'conflitoCom': {
              'id': 'p1',
              'dataInicio': '2026-10-18',
              'dataLimite': '2026-10-31',
            },
          },
        );

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();
        await publicar(tester);

        expect(
          find.text(
            'Já existe um panfleto nesse período. Ele conflita com o panfleto de 18/10/2026 a 31/10/2026.',
          ),
          findsOneWidget,
        );
        expect(find.byType(PanfletoFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a API com erro na data limite, quando publico, então o erro aparece no próprio campo',
      (tester) async {
        const mensagem =
            'A data limite não pode ser anterior à data de início nem a hoje.';
        escolherImagem(() async => imagem());
        await abrir(tester);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'DATA_LIMITE_INVALIDA',
          mensagem: mensagem,
          campos: {
            'dataLimite': [mensagem],
          },
        );

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();
        await publicar(tester);

        expect(find.text(mensagem), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado o conflito com um panfleto sem data limite, quando publico, então aviso desde quando ele vale',
      (tester) async {
        escolherImagem(() async => imagem());
        await abrir(tester);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'PANFLETO_PERIODO_SOBREPOSTO',
          mensagem: 'Já existe um panfleto nesse período.',
          detalhes: {
            'conflitoCom': {
              'id': 'p1',
              'dataInicio': '2026-10-18',
              'dataLimite': null,
            },
          },
        );

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();
        await publicar(tester);

        expect(
          find.text(
            'Já existe um panfleto nesse período. Ele conflita com o panfleto que começa em 18/10/2026, sem data limite.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado as datas salvas e a imagem recusada, quando salvo, então a lista já mostra as datas novas e aviso o erro',
      (tester) async {
        final mock = _PanfletoRepositoryMock();
        final comDatas = PanfletoResponse(
          id: panfletoFake.id,
          filialId: panfletoFake.filialId,
          urlImagem: panfletoFake.urlImagem,
          largura: panfletoFake.largura,
          altura: panfletoFake.altura,
          vigencia: Vigencia(
            dataInicio: panfletoFake.vigencia.dataInicio,
            dataLimite: DateTime(2027, 1, 15),
            situacao: SituacaoVigencia.vigente,
            editavel: true,
          ),
          criadoEm: panfletoFake.criadoEm,
        );
        when(() => mock.listar(any()))
            .thenAnswer((_) async => Success([panfletoFake]));
        when(() => mock.editar(any(), any(), any()))
            .thenAnswer((_) async => Success(comDatas));
        when(
          () => mock.trocarImagem(
            any(),
            any(),
            bytes: any(named: 'bytes'),
            nomeArquivo: any(named: 'nomeArquivo'),
          ),
        ).thenAnswer((_) async => const Failure(FalhaSemConexao()));
        final panfletos = panfletosControllerDeTeste(repository: mock);
        await tester.runAsync(() => panfletos.carregar(filialFake.id));
        final form = panfletoFormControllerDeTeste(repository: mock)
          ..escolherImagem(Uint8List.fromList([1]), 'novo.png');
        tester.view.physicalSize = const Size(390, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          montarTela(
            PanfletoFormScreen(filialId: filialFake.id, panfleto: panfletoFake),
            panfletos: panfletos,
            panfletoForm: form,
            seletorImagem: seletor,
          ),
        );
        await tester.pumpAndSettle();

        tester
            .widget<AppCampoData>(
              find.widgetWithText(AppCampoData, 'Data limite (opcional)'),
            )
            .aoMudar(DateTime(2027, 1, 15));
        await tester.pump();
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Salvar panfleto'),
        );
        await tester.pumpAndSettle();

        expect(panfletos.panfletos.single, comDatas);
        expect(find.text(const FalhaSemConexao().mensagem), findsOneWidget);
        expect(find.byType(PanfletoFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto vigente, então a data de início fica bloqueada e explica o motivo (RN26)',
      (tester) async {
        await abrir(tester, panfleto: panfletoFake);

        expect(find.text('Editar panfleto'), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(_campo('Data de início (opcional)'))
              .enabled,
          isFalse,
        );
        expect(
          find.text('Panfleto vigente: a data de início não muda mais.'),
          findsOneWidget,
        );
        expect(find.byTooltip('Limpar data limite (opcional)'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto agendado, então a data de início pode ser alterada',
      (tester) async {
        await abrir(tester, panfleto: panfletoFakeAgendado);

        expect(
          tester
              .widget<TextFormField>(_campo('Data de início (opcional)'))
              .enabled,
          isTrue,
        );
      },
    );

    testWidgets(
      'Cenário: Dado um panfleto, quando troco a imagem e salvo, então envio só a imagem, atualizo a lista e saio',
      (tester) async {
        escolherImagem(() async => imagem('novo.png'));
        final panfletos = panfletosControllerDeTeste(repository: repository);
        await tester.runAsync(() => panfletos.carregar(filialFake.id));
        await abrir(tester, panfleto: panfletoFake, panfletos: panfletos);

        await tester.tap(find.text('Trocar imagem'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Salvar panfleto'),
        );
        await tester.pumpAndSettle();

        expect(repository.imagensEnviadas, ['novo.png']);
        expect(repository.pedidos, isEmpty);
        expect(
          panfletos.panfletos.single.urlImagem,
          'https://midia.fake/panfleto/novo.png',
        );
        expect(find.byType(PanfletoFormScreen), findsNothing);
      },
    );
  });
}
