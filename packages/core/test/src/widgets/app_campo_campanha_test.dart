import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: Campanha do banner (U5, U6)', () {
    late TextEditingController descricao;

    setUp(() => descricao = TextEditingController());
    tearDown(() => descricao.dispose());

    Future<void> desenhar(
      WidgetTester tester, {
      required TipoCampanha tipo,
      ValueChanged<TipoCampanha>? aoMudarTipo,
      VoidCallback? aoEscolherFoto,
      bool habilitado = true,
    }) => tester.pumpWidget(
      montarComMarca(
        SingleChildScrollView(
          child: AppCampoCampanha(
            tipo: tipo,
            descricao: descricao,
            aoMudarTipo: aoMudarTipo,
            aoEscolherFoto: aoEscolherFoto,
            bytesFoto: pngQrCodeFake,
            habilitado: habilitado,
          ),
        ),
      ),
    );

    testWidgets(
      'Cenário: Dado Foto, quando desenho, então o campo de imagem em 16:9 e nenhum texto',
      (tester) async {
        var escolhas = 0;
        await desenhar(
          tester,
          tipo: TipoCampanha.foto,
          aoEscolherFoto: () => escolhas++,
        );

        final campo = tester.widget<AppCampoImagem>(
          find.byType(AppCampoImagem),
        );
        expect(campo.proporcao, 16 / 9);
        expect(find.byType(TextFormField), findsNothing);
        await tester.tap(find.text('Trocar imagem'));
        expect(escolhas, 1);
      },
    );

    testWidgets(
      'Cenário: Dado Descrição, quando desenho, então texto multilinha com contador de 280',
      (tester) async {
        await desenhar(tester, tipo: TipoCampanha.descricao);

        expect(find.byType(AppCampoImagem), findsNothing);
        expect(find.text('0/280'), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), 'x' * 300);
        expect(descricao.text.length, 280);
      },
    );

    testWidgets(
      'Cenário: Dado Nenhuma, quando toco em "Foto", então aoMudarTipo recebe foto',
      (tester) async {
        final tipos = <TipoCampanha>[];
        await desenhar(
          tester,
          tipo: TipoCampanha.nenhuma,
          aoMudarTipo: tipos.add,
        );

        expect(find.byType(AppCampoImagem), findsNothing);
        await tester.tap(find.text('Foto'));

        expect(tipos, [TipoCampanha.foto]);
      },
    );

    testWidgets(
      'Cenário: Dado desabilitado, quando toco em "Descrição", então nada muda',
      (tester) async {
        final tipos = <TipoCampanha>[];
        await desenhar(
          tester,
          tipo: TipoCampanha.foto,
          aoMudarTipo: tipos.add,
          habilitado: false,
        );

        await tester.tap(find.text('Descrição'));

        expect(tipos, isEmpty);
      },
    );
  });
}
