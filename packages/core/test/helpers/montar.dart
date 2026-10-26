import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

Widget montarComMarca(Widget filho) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.claro(),
  home: Scaffold(body: Center(child: filho)),
);

Future<void> precarregarLogo(WidgetTester tester) => tester.runAsync(
  () => Future.wait([
    for (final elemento in find.byType(MarcaLogo).evaluate())
      precacheImage(AppMarca.logo, elemento),
  ]),
);
