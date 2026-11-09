import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

const _topico = TopicoSuporte(
  titulo: 'Filiais',
  icone: Icons.storefront_outlined,
  resumo: 'Cada filial tem a própria página.',
  passos: ['Toque em "Nova filial".', 'Toque em "Salvar filial".'],
  dicas: ['Confira a filial em uso.'],
);

void main() {
  group('Funcionalidade: tópico do suporte', () {
    testWidgets(
      'Cenário: Dado um tópico fechado, então mostra número, título e resumo, sem o passo a passo',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const SingleChildScrollView(
              child: AppTopicoSuporte(topico: _topico, numero: 3),
            ),
          ),
        );

        expect(find.text('3. Filiais'), findsOneWidget);
        expect(find.text('Cada filial tem a própria página.'), findsOneWidget);
        expect(find.text('Passo a passo'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado um tópico fechado, quando toco nele, então mostra os passos numerados e as dicas',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const SingleChildScrollView(
              child: AppTopicoSuporte(topico: _topico, numero: 3),
            ),
          ),
        );

        await tester.tap(find.text('3. Filiais'));
        await tester.pumpAndSettle();

        expect(find.text('Passo a passo'), findsOneWidget);
        expect(find.text('1.'), findsOneWidget);
        expect(find.text('Toque em "Nova filial".'), findsOneWidget);
        expect(find.text('2.'), findsOneWidget);
        expect(find.text('Dicas'), findsOneWidget);
        expect(find.text('Confira a filial em uso.'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um tópico sem dicas aberto, então não mostra o quadro de dicas',
      (tester) async {
        await tester.pumpWidget(
          montarComMarca(
            const SingleChildScrollView(
              child: AppTopicoSuporte(
                topico: TopicoSuporte(
                  titulo: 'Problemas comuns',
                  icone: Icons.help_outline,
                  resumo: 'O que fazer.',
                  passos: ['Tente de novo.'],
                ),
                numero: 9,
                inicialmenteAberto: true,
              ),
            ),
          ),
        );

        expect(find.text('Tente de novo.'), findsOneWidget);
        expect(find.text('Dicas'), findsNothing);
      },
    );
  });

  group('Funcionalidade: guia de suporte', () {
    test(
      'Cenário: Dado o guia, então segue a jornada do cadastro até divulgar a página',
      () {
        expect([for (final t in guiaSuporte) t.titulo], [
          'Conta e acesso',
          'Perfil e identidade',
          'Filiais',
          'Categorias',
          'Produtos',
          'Panfletos',
          'Página',
          'Divulgar a página',
          'Problemas comuns',
        ]);
      },
    );

    test('Cenário: Dado cada tópico do guia, então ele tem resumo e passos', () {
      for (final topico in guiaSuporte) {
        expect(topico.resumo, isNotEmpty, reason: topico.titulo);
        expect(topico.passos, isNotEmpty, reason: topico.titulo);
      }
    });
  });
}
