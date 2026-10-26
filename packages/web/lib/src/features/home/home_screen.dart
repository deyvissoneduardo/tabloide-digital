import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/filiais/widgets/secao_filiais.dart';
import 'package:tabloide_web/src/features/home/widgets/resumo_inicio.dart';
import 'package:tabloide_web/src/features/panfletos/widgets/secao_panfletos.dart';
import 'package:tabloide_web/src/features/perfil/perfil_screen.dart';
import 'package:tabloide_web/src/features/produtos/widgets/secao_produtos.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _abrirPerfil(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const PerfilScreen()));

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final classe = ClasseTamanho.de(context);
    final conteudo = switch (controller.secao) {
      SecaoPainel.inicio => const ResumoInicio(),
      SecaoPainel.filiais => const SecaoFiliais(),
      SecaoPainel.panfletos => const SecaoPanfletos(),
      SecaoPainel.produtos => const SecaoProdutos(),
    };

    if (classe == ClasseTamanho.compacto) {
      return Scaffold(
        appBar: AppBar(
          title: const AppMarcaCabecalho(),
          actions: [
            IconButton(
              tooltip: 'Perfil',
              icon: const Icon(Icons.person_outline),
              onPressed: () => _abrirPerfil(context),
            ),
          ],
        ),
        body: conteudo,
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.secao.index,
          onDestinationSelected: _selecionar(context),
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

    final expandido = classe == ClasseTamanho.expandido;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: expandido,
            labelType: expandido
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppEspacamentos.md),
              child: expandido
                  ? const SizedBox(
                      width: AppLayout.larguraMenuLateral,
                      child: AppMarcaCabecalho(),
                    )
                  : const MarcaLogo(altura: AppIcones.destaque),
            ),
            trailingAtBottom: true,
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: AppEspacamentos.md),
              child: expandido
                  ? TextButton.icon(
                      onPressed: () => _abrirPerfil(context),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Perfil'),
                    )
                  : IconButton(
                      tooltip: 'Perfil',
                      icon: const Icon(Icons.person_outline),
                      onPressed: () => _abrirPerfil(context),
                    ),
            ),
            selectedIndex: controller.secao.index,
            onDestinationSelected: _selecionar(context),
            destinations: [
              for (final s in SecaoPainel.values)
                NavigationRailDestination(
                  icon: Icon(s.icone),
                  selectedIcon: Icon(s.iconeSelecionado),
                  label: Text(s.titulo),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.larguraMaximaConteudo,
                ),
                child: conteudo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ValueChanged<int> _selecionar(BuildContext context) =>
      (i) => context.read<HomeController>().selecionar(SecaoPainel.values[i]);
}
