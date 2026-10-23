import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/src/features/home/home_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Raiz do painel web; na web o `title` vira o título da aba; nome e tema vêm da marca do build.
class PainelWeb extends StatelessWidget {
  const PainelWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final marca = context.read<BrandConfig>();
    return MaterialApp(
      title: marca.nome,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(marca),
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
