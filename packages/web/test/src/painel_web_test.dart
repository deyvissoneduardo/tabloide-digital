import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../helpers/montar.dart';

void main() {
  group('Funcionalidade: raiz do painel web', () {
    testWidgets(
      'Cenário: Dado o painel, quando a web abre, então o título da aba e o tema (só claro) são do Tabloide Digital e sem sessão no cache o login aparece',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<Sessao>.value(value: sessaoDeTeste()),
              ChangeNotifierProvider(create: (_) => loginControllerDeTeste()),
              ChangeNotifierProvider(create: (_) => filiaisControllerDeTeste()),
            ],
            child: const PainelWeb(),
          ),
        );
        await tester.pumpAndSettle();

        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.title, 'Tabloide Digital');
        expect(app.theme?.colorScheme.primary, AppCores.primaria);
        expect(app.darkTheme, isNull);
        expect(app.themeMode, ThemeMode.light);
        expect(app.locale, const Locale('pt', 'BR'));
        expect(
          Localizations.localeOf(tester.element(find.byType(Scaffold).first)),
          const Locale('pt', 'BR'),
        );
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );
  });
}
