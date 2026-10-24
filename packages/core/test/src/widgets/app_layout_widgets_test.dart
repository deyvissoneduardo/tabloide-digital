import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

void main() {
  group('Funcionalidade: formulário do painel', () {
    testWidgets(
      'Cenário: Dado uma janela larga, então o formulário fica limitado à largura máxima e a chave controla a validação',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final chave = GlobalKey<FormState>();

        await tester.pumpWidget(
          montarComMarca(
            AppFormulario(
              chave: chave,
              children: [TextFormField(validator: (_) => 'erro')],
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(Form)).width,
          AppLayout.larguraMaximaFormulario,
        );
        expect(chave.currentState!.validate(), isFalse);
      },
    );
  });

  group('Funcionalidade: marca no topo das telas', () {
    testWidgets(
      'Cenário: Dado a marca "Mercado Bom Preço", então o destaque e o cabeçalho mostram logo e nome',
      (tester) async {
        const marca = MarcaFake(nome: 'Mercado Bom Preço');
        for (final widget in const [AppMarcaDestaque(), AppMarcaCabecalho()]) {
          await tester.pumpWidget(montarComMarca(widget, marca: marca));

          expect(find.text('Mercado Bom Preço'), findsOneWidget);
          expect(
            find.bySemanticsLabel('Logo de Mercado Bom Preço'),
            findsOneWidget,
          );
        }
        expect(
          tester.widget<MarcaLogo>(find.byType(MarcaLogo)).altura,
          isNot(AppIcones.destaque),
          reason: 'o cabeçalho usa a logo pequena',
        );
        await tester.pumpWidget(
          montarComMarca(const AppMarcaDestaque(), marca: marca),
        );
        expect(
          tester.widget<MarcaLogo>(find.byType(MarcaLogo)).altura,
          AppIcones.destaque,
        );
      },
    );
  });

  group('Funcionalidade: conteúdo de seção ainda não implementada', () {
    testWidgets(
      'Cenário: Dado a seção Produtos, então mostra o ícone e o título dela com "Em breve"',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(const AppConteudoSecao(secao: SecaoPainel.produtos)),
        );

        expect(find.text('Produtos'), findsOneWidget);
        expect(find.text('Em breve'), findsOneWidget);
        expect(
          find.byIcon(SecaoPainel.produtos.iconeSelecionado),
          findsOneWidget,
        );
      },
    );
  });
}
