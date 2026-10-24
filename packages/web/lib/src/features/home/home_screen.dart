import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final classe = ClasseTamanho.de(context);
    final conteudo = AppConteudoSecao(secao: controller.secao);

    if (classe == ClasseTamanho.compacto) {
      return Scaffold(
        appBar: AppBar(title: const AppMarcaCabecalho()),
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
