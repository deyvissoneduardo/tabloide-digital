import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/filiais/inicio_sessao_screen.dart';

class PainelWeb extends StatelessWidget {
  const PainelWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppMarca.nome,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      themeMode: ThemeMode.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const InicioSessaoScreen(),
    );
  }
}
