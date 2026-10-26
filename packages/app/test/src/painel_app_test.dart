import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../helpers/montar.dart';

void main() {
  group('Funcionalidade: raiz do painel mobile', () {
    testWidgets(
      'Cenário: Dado a marca "Padaria Central", quando o app abre, então título e tema (só claro) vêm da marca e sem sessão no cache o login aparece',
      (tester) async {
        const marca = MarcaFake(
          nome: 'Padaria Central',
          corPrimaria: Color(0xFFC62828),
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<BrandConfig>.value(value: marca),
              Provider<Sessao>.value(value: sessaoDeTeste()),
              ChangeNotifierProvider(create: (_) => loginControllerDeTeste()),
              ChangeNotifierProvider(create: (_) => filiaisControllerDeTeste()),
            ],
            child: const PainelApp(),
          ),
        );
        await tester.pumpAndSettle();

        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.title, 'Padaria Central');
        expect(app.theme?.colorScheme.primary, marca.corPrimaria);
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
