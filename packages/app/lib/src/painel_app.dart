import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/inicio_sessao_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';

class PainelApp extends StatelessWidget {
  const PainelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final marca = context.read<BrandConfig>();
    return MaterialApp(
      title: marca.nome,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(marca),
      themeMode: ThemeMode.light,
      home: const InicioSessaoScreen(),
    );
  }
}
