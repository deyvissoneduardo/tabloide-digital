import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/home/widgets/conteudo_secao.dart';
import 'package:tabloide_app/src/features/home/widgets/resumo_inicio.dart';
import 'package:tabloide_core/tabloide_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final secao = context.watch<HomeController>().secao;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppEspacamentos.md,
        title: const Row(
          children: [
            MarcaLogo(),
            SizedBox(width: AppEspacamentos.sm),
            Expanded(child: MarcaNome()),
          ],
        ),
      ),
      body: secao == SecaoPainel.inicio
          ? const ResumoInicio()
          : ConteudoSecao(secao: secao),
      bottomNavigationBar: NavigationBar(
        selectedIndex: secao.index,
        onDestinationSelected: (i) =>
            context.read<HomeController>().selecionar(SecaoPainel.values[i]),
        destinations: [
          for (final s in SecaoPainel.values)
            NavigationDestination(
              icon: Icon(s.icone),
              selectedIcon: Icon(s.iconeSelecionado),
              label: s.titulo,
            ),
        ],
      ),
    );
  }
}
