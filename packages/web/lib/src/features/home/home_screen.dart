import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_web/src/features/filiais/widgets/secao_filiais.dart';
import 'package:tabloide_web/src/features/login/login_controller.dart';
import 'package:tabloide_web/src/features/login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _sair(BuildContext context) async {
    final confirmou = await confirmar(
      context,
      titulo: 'Sair do painel?',
      mensagem: 'Você vai precisar entrar de novo com e-mail e senha.',
      rotuloConfirmar: 'Sair',
    );
    if (!confirmou || !context.mounted) return;
    final navegador = Navigator.of(context);
    final filiais = context.read<FiliaisController>();
    final home = context.read<HomeController>();
    await context.read<LoginController>().sair();
    filiais.limpar();
    home.selecionar(SecaoPainel.inicio);
    await navegador.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final classe = ClasseTamanho.de(context);
    final conteudo = switch (controller.secao) {
      SecaoPainel.filiais => const SecaoFiliais(),
      final secao => AppConteudoSecao(secao: secao),
    };

    if (classe == ClasseTamanho.compacto) {
      return Scaffold(
        appBar: AppBar(
          title: const AppMarcaCabecalho(),
          actions: [
            IconButton(
              tooltip: 'Sair',
              icon: const Icon(Icons.logout),
              onPressed: () => _sair(context),
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
                      onPressed: () => _sair(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair'),
                    )
                  : IconButton(
                      tooltip: 'Sair',
                      icon: const Icon(Icons.logout),
                      onPressed: () => _sair(context),
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
