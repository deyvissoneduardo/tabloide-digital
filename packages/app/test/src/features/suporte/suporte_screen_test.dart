import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';

import '../../../helpers/montar.dart';

void main() {
  group('Funcionalidade: suporte no app', () {
    Future<void> abrirHome(WidgetTester tester) async {
      final filiais = filiaisControllerDeTeste();
      await tester.runAsync(filiais.carregar);
      await tester.pumpWidget(
        montar(controller: controllerDeTeste(), filiais: filiais),
      );
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado a home aberta, quando toco em Suporte, então abre o guia com todos os tópicos na ordem da jornada',
      (tester) async {
        await abrirHome(tester);

        await tester.tap(find.byTooltip('Suporte'));
        await tester.pumpAndSettle();

        expect(find.byType(SuporteScreen), findsOneWidget);
        expect(find.text('Do cadastro à página no ar'), findsOneWidget);
        for (final (i, topico) in guiaSuporte.indexed) {
          await tester.scrollUntilVisible(
            find.text('${i + 1}. ${topico.titulo}'),
            AppEspacamentos.xl,
          );
          expect(find.text('${i + 1}. ${topico.titulo}'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'Cenário: Dado o suporte aberto, quando toco em Página, então mostra o passo a passo de publicar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.claro(), home: const SuporteScreen()),
        );
        final titulo = find.text('7. Página');
        await tester.scrollUntilVisible(titulo, AppEspacamentos.xl);
        await tester.ensureVisible(titulo);
        await tester.pumpAndSettle();

        await tester.tap(titulo);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Toque em "Publicar". A página atualiza'),
          findsOneWidget,
        );
      },
    );
  });
}
