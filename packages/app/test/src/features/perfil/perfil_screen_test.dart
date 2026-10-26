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

  group('Funcionalidade: perfil no app', () {
    late LojistaRepositoryFake lojista;
    late IdentidadeRepositoryFake identidade;
    late _ImagePickerMock seletor;

    setUp(() {
      lojista = LojistaRepositoryFake();
      identidade = IdentidadeRepositoryFake();
      seletor = _ImagePickerMock();
    });

    Future<void> abrir(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        montarTela(
          const PerfilScreen(),
          perfil: perfilControllerDeTeste(
            lojista: lojista,
            identidade: identidade,
          ),
          seletorImagem: seletor,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> salvar(WidgetTester tester) async {
      await tester.tap(find.text('Salvar'));
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
      'Cenário: Dado lojista e identidade na API, quando abro o perfil, então os dados da loja vêm antes da identidade, com máscaras e e-mail só leitura',
      (tester) async {
        await abrir(tester);

        expect(find.text('Perfil'), findsOneWidget);
        expect(find.text('ana@bompreco.com.br'), findsOneWidget);
        expect(tester.widget<TextFormField>(_campo('E-mail')).enabled, isFalse);
        expect(find.text('Mercado Bom Preço'), findsOneWidget);
        expect(find.text('Ana Souza'), findsOneWidget);
        expect(find.text('(11) 98765-4321'), findsOneWidget);
        expect(find.text('77.343.168/0001-24'), findsOneWidget);
        expect(find.text('#C8102E'), findsOneWidget);
        expect(find.text('#FFD100'), findsOneWidget);
        expect(
          tester.getTopLeft(_campo('CNPJ')).dy,
          lessThan(tester.getTopLeft(find.byType(AppLogoIdentidade)).dy),
        );
      },
    );

    testWidgets(
      'Cenário: Dado a API fora do ar, quando abro e tento de novo com ela de volta, então os campos aparecem',
      (tester) async {
        lojista.falhaSimulada = const FalhaSemConexao();
        await abrir(tester);

        expect(find.byType(EstadoFalha), findsOneWidget);
        lojista.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.text('Ana Souza'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado os dados alterados, quando salvo, então envio os dois PATCH com o mesmo nome fantasia e aviso que salvou',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('Nome fantasia'), 'Mercado Novo');
        await tester.enterText(_campo('Nome do responsável'), 'Bia');
        await tester.enterText(_campo('Cor secundária'), '');
        await salvar(tester);

        expect(
          lojista.pedidos.single,
          const LojistaRequest(
            nomeFantasia: 'Mercado Novo',
            nomeResponsavel: 'Bia',
            whatsapp: '11987654321',
            cnpj: '77343168000124',
          ),
        );
        expect(
          identidade.pedidos.single,
          const IdentidadeRequest(
            nomeFantasia: 'Mercado Novo',
            corPrimaria: '#C8102E',
          ),
        );
        expect(find.text('Perfil salvo.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado campos obrigatórios vazios e cor incompleta, quando salvo, então mostro os erros nos campos e não chamo a API',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('Nome fantasia'), '');
        await tester.enterText(_campo('Nome do responsável'), '');
        await tester.enterText(_campo('WhatsApp (com DDD)'), '');
        await tester.enterText(_campo('CNPJ'), '');
        await tester.enterText(_campo('Cor primária'), '#C81');
        await salvar(tester);

        expect(find.text('Informe o nome fantasia.'), findsOneWidget);
        expect(find.text('Informe o nome do responsável.'), findsOneWidget);
        expect(find.text('Informe o WhatsApp.'), findsOneWidget);
        expect(find.text('Informe o CNPJ.'), findsOneWidget);
        expect(find.text('Informe a cor no formato #RRGGBB.'), findsOneWidget);
        expect(lojista.pedidos, isEmpty);
        expect(identidade.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando o WhatsApp, quando salvo, então o erro aparece no campo sem aviso',
      (tester) async {
        await abrir(tester);
        lojista.falhaSimulada = const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'whatsapp': ['Informe um WhatsApp válido com DDD.'],
          },
        );

        await salvar(tester);

        expect(
          find.text('Informe um WhatsApp válido com DDD.'),
          findsOneWidget,
        );
        expect(find.text('Dados inválidos.'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado a conta desativada, quando salvo, então aviso a mensagem da API',
      (tester) async {
        await abrir(tester);
        lojista.falhaSimulada = const FalhaApi(
          codigo: 'LOJISTA_DESATIVADO',
          mensagem: 'Sua conta está desativada. O painel está disponível só para consulta.',
        );

        await salvar(tester);

        expect(
          find.text(
            'Sua conta está desativada. O painel está disponível só para consulta.',
          ),
          findsOneWidget,
        );
        expect(identidade.pedidos, isEmpty);
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

        expect(identidade.logosEnviados, ['logo.png']);
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

        expect(identidade.logosEnviados, isEmpty);
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
        identidade.falhaSimulada = const FalhaApi(
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
