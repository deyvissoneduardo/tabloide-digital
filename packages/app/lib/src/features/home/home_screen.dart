import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/widgets/secao_filiais.dart';
import 'package:tabloide_app/src/features/home/widgets/resumo_inicio.dart';
import 'package:tabloide_app/src/features/panfletos/widgets/secao_panfletos.dart';
import 'package:tabloide_app/src/features/perfil/perfil_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _abrirPerfil(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const PerfilScreen()));

  @override
  Widget build(BuildContext context) {
    final secao = context.watch<HomeController>().secao;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppEspacamentos.md,
        title: const AppMarcaCabecalho(),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => _abrirPerfil(context),
          ),
        ],
      ),
      body: switch (secao) {
        SecaoPainel.inicio => const ResumoInicio(),
        SecaoPainel.filiais => const SecaoFiliais(),
        SecaoPainel.panfletos => const SecaoPanfletos(),
        _ => AppConteudoSecao(secao: secao),
      },
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
