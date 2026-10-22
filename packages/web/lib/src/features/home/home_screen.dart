import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/home/widgets/conteudo_secao.dart';

/// Home do painel no navegador: menu lateral em telas largas e o mesmo
/// layout do celular em telas estreitas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Abaixo disso, usa navegação embaixo (lojista no celular).
  static const larguraCompacta = 600.0;

  /// A partir disso, o menu lateral mostra os rótulos ao lado dos ícones.
  static const larguraExpandida = 1200.0;

  /// Largura máxima do conteúdo, centralizado.
  static const larguraMaximaConteudo = 1200.0;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final largura = MediaQuery.sizeOf(context).width;
    final conteudo = ConteudoSecao(secao: controller.secao);

    if (largura < larguraCompacta) {
      return Scaffold(
        appBar: AppBar(title: const _Marca()),
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

    final expandido = largura >= larguraExpandida;
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
                  ? const SizedBox(width: 220, child: _Marca())
                  : const MarcaLogo(altura: 40),
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
                  maxWidth: larguraMaximaConteudo,
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

class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      MarcaLogo(),
      SizedBox(width: AppEspacamentos.sm),
      Flexible(child: MarcaNome()),
    ],
  );
}
