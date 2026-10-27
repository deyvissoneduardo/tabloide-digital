import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _maisDePdf = FalhaApi(
  codigo: 'PDF_COM_VARIAS_PAGINAS',
  mensagem: 'O PDF do panfleto precisa ter só 1 página.',
);

const _erro2Mb =
    'O PDF pode ter até 2 MB. Exporte o PDF otimizado para web e tente de novo.';

ArquivoEscolhido _pdf(int bytes, [String nome = 'ofertas.pdf']) =>
    (bytes: Uint8List(bytes), nome: nome);

void main() {
  group('Funcionalidade: Panfleto em PDF no formulário (RN13)', () {
    late PanfletoRepositoryFake repository;

    setUp(() => repository = PanfletoRepositoryFake(panfletos: [panfletoFake]));

    Future<void> abrir(
      WidgetTester tester, {
      PanfletoResponse? panfleto,
      SeletorPdf? seletorPdf,
    }) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        montarTela(
          PanfletoFormScreen(filialId: filialFake.id, panfleto: panfleto),
          panfletoRepository: repository,
          seletorPdf: seletorPdf,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> escolherPdf(WidgetTester tester) async {
      await tester.tap(find.text('Escolher PDF'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado um PDF de 1 MB escolhido, quando salvo, então criar é chamado com nomeArquivo .pdf',
      (tester) async {
        await abrir(tester, seletorPdf: SeletorPdfDeTeste(_pdf(1024 * 1024)));

        await escolherPdf(tester);
        expect(find.text('ofertas.pdf'), findsOneWidget);
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Publicar panfleto'),
        );
        await tester.pumpAndSettle();

        expect(repository.imagensEnviadas, ['ofertas.pdf']);
        expect(repository.panfletos.last.tipo, TipoArquivoPanfleto.pdf);
      },
    );

    testWidgets(
      'Cenário: Dado um PDF de 3 MB, quando escolho, então aparece o erro de 2 MB no campo e nada é enviado',
      (tester) async {
        await abrir(
          tester,
          seletorPdf: SeletorPdfDeTeste(_pdf(3 * 1024 * 1024, 'grande.pdf')),
        );

        await escolherPdf(tester);

        expect(find.text(_erro2Mb), findsOneWidget);
        expect(find.text('grande.pdf'), findsNothing);
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Publicar panfleto'),
        );
        await tester.pumpAndSettle();
        expect(repository.imagensEnviadas, isEmpty);
      },
    );

    test('Cenário: Dado uma imagem de 3 MB, quando escolho, então é aceita (limite de imagem continua 10 MB)', () {
      final controller = panfletoFormControllerDeTeste()
        ..escolherArquivo(Uint8List(3 * 1024 * 1024), 'folheto.jpg');

      expect(controller.imagem?.nome, 'folheto.jpg');
      expect(controller.erroDoCampo('imagem'), isNull);
      expect(controller.arquivoEhPdf(), isFalse);
    });

    test('Cenário: Dado a API devolve PDF_COM_VARIAS_PAGINAS, quando salvo, então a mensagem aparece no campo imagem', () async {
      final controller = panfletoFormControllerDeTeste(
        repository: PanfletoRepositoryFake(falhaSimulada: _maisDePdf),
      )..escolherArquivo(Uint8List(10), 'ofertas.pdf');

      await controller.salvar(filialId: filialFake.id);

      expect(controller.erroDoCampo('imagem'), _maisDePdf.mensagem);
    });

    testWidgets(
      'Cenário: Dado edição de um panfleto PDF, quando abro, então o campo mostra o estado PDF com o nome do arquivo',
      (tester) async {
        repository.panfletos.add(panfletoFakePdf);
        await abrir(tester, panfleto: panfletoFakePdf);

        expect(find.text('0192f0c2.pdf'), findsOneWidget);
        expect(find.byIcon(Icons.picture_as_pdf_outlined), findsWidgets);
        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado o seletor de arquivo cancelado, quando toco em "Escolher PDF", então nada muda',
      (tester) async {
        await abrir(tester, seletorPdf: const SeletorPdfDeTeste());

        await escolherPdf(tester);

        expect(find.text('PDF de 1 página'), findsNothing);
        expect(
          find.bySemanticsLabel('Nenhuma imagem escolhida'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado o formulário, então o rótulo e a ajuda citam imagem e PDF',
      (tester) async {
        await abrir(tester);

        expect(find.text('Imagem ou PDF do panfleto'), findsOneWidget);
        expect(
          find.text(
            'JPEG, PNG ou WebP até 10 MB, ou PDF de 1 página até 2 MB.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
