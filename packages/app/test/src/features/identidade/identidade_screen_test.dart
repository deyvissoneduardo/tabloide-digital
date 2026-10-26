import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

class _ImagePickerMock extends Mock implements ImagePicker {}

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

void main() {
  setUpAll(() => registerFallbackValue(ImageSource.gallery));

  group('Funcionalidade: identidade visual no app', () {
    late IdentidadeRepositoryFake repository;
    late _ImagePickerMock seletor;

    setUp(() {
      repository = IdentidadeRepositoryFake();
      seletor = _ImagePickerMock();
    });

    Future<void> abrir(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        montarTela(
          const IdentidadeScreen(),
          identidade: identidadeControllerDeTeste(repository: repository),
          seletorImagem: seletor,
        ),
      );
      await tester.pumpAndSettle();
    }

    void escolherImagem(Future<XFile?> Function() resposta) => when(
      () => seletor.pickImage(
        source: any(named: 'source'),
        maxWidth: any(named: 'maxWidth'),
        maxHeight: any(named: 'maxHeight'),
      ),
    ).thenAnswer((_) => resposta());

    testWidgets(
      'Cenário: Dado a identidade na API, quando abro a tela, então os campos vêm preenchidos',
      (tester) async {
        await abrir(tester);

        expect(find.text('Identidade visual'), findsOneWidget);
        expect(find.text('Mercado Bom Preço'), findsOneWidget);
        expect(find.text('#C8102E'), findsOneWidget);
        expect(find.text('#FFD100'), findsOneWidget);
        expect(find.byType(AppLogoIdentidade), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado a API fora do ar, quando abro e tento de novo com ela de volta, então os campos aparecem',
      (tester) async {
        repository.falhaSimulada = const FalhaSemConexao();
        await abrir(tester);

        expect(find.byType(EstadoFalha), findsOneWidget);
        repository.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.text('Mercado Bom Preço'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado nome e cores alterados, quando salvo, então envio o pedido e aviso que salvou',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('Nome fantasia'), 'Mercado Novo');
        await tester.enterText(_campo('Cor secundária'), '');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(
          repository.pedidos.single,
          const IdentidadeRequest(
            nomeFantasia: 'Mercado Novo',
            corPrimaria: '#C8102E',
          ),
        );
        expect(find.text('Identidade visual salva.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado nome vazio e cor incompleta, quando salvo, então mostro os erros nos campos e não chamo a API',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('Nome fantasia'), '');
        await tester.enterText(_campo('Cor primária'), '#C81');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(find.text('Informe o nome fantasia.'), findsOneWidget);
        expect(find.text('Informe a cor no formato #RRGGBB.'), findsOneWidget);
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando a cor, quando salvo, então o erro aparece no campo sem aviso',
      (tester) async {
        await abrir(tester);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'corPrimaria': ['Informe a cor no formato #RRGGBB.'],
          },
        );

        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(find.text('Informe a cor no formato #RRGGBB.'), findsOneWidget);
        expect(find.text('Dados inválidos.'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado a API sem conexão, quando salvo, então aviso a falha',
      (tester) async {
        await abrir(tester);
        repository.falhaSimulada = const FalhaSemConexao();

        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(find.text(const FalhaSemConexao().mensagem), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado uma imagem escolhida, quando troco o logo, então envio o arquivo e aviso que atualizou',
      (tester) async {
        escolherImagem(
          () async => XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            name: 'logo.png',
            path: 'logo.png',
          ),
        );
        await abrir(tester);

        await tester.tap(find.text('Trocar logo'));
        await tester.pumpAndSettle();

        expect(repository.logosEnviados, ['logo.png']);
        expect(find.text('Logo atualizado.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o seletor fechado sem imagem, quando troco o logo, então nada é enviado',
      (tester) async {
        escolherImagem(() async => null);
        await abrir(tester);

        await tester.tap(find.text('Trocar logo'));
        await tester.pumpAndSettle();

        expect(repository.logosEnviados, isEmpty);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando a imagem, quando troco o logo, então aviso a mensagem da API',
      (tester) async {
        escolherImagem(
          () async => XFile.fromData(
            Uint8List.fromList([1]),
            name: 'animacao.gif',
            path: 'animacao.gif',
          ),
        );
        await abrir(tester);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'IMAGEM_INVALIDA',
          mensagem: 'Envie uma imagem JPEG, PNG ou WebP válida.',
        );

        await tester.tap(find.text('Trocar logo'));
        await tester.pumpAndSettle();

        expect(
          find.text('Envie uma imagem JPEG, PNG ou WebP válida.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado o acesso às imagens negado, quando troco o logo, então aviso como resolver',
      (tester) async {
        escolherImagem(
          () async => throw PlatformException(code: 'photo_access_denied'),
        );
        await abrir(tester);

        await tester.tap(find.text('Trocar logo'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Não conseguimos abrir suas imagens. Verifique a permissão e tente de novo.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
