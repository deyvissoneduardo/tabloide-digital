import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../helpers/montar.dart';

void main() {
  group('Funcionalidade: raiz do painel web', () {
    testWidgets(
      'Cenário: Dado a marca "Padaria Central", quando a web abre, então o título da aba e o tema (só claro) vêm da marca e a home aparece',
      (tester) async {
        const marca = MarcaFake(
          nome: 'Padaria Central',
          corPrimaria: Color(0xFFC62828),
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<BrandConfig>.value(value: marca),
              ChangeNotifierProvider(create: (_) => controllerDeTeste()),
            ],
            child: const PainelWeb(),
          ),
        );

        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.title, 'Padaria Central');
        expect(app.theme?.colorScheme.primary, marca.corPrimaria);
        expect(app.darkTheme, isNull);
        expect(app.themeMode, ThemeMode.light);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });
}
