import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/filiais/widgets/secao_filiais.dart';
import 'package:tabloide_app/src/features/home/widgets/resumo_inicio.dart';
import 'package:tabloide_app/src/features/login/login_controller.dart';
import 'package:tabloide_app/src/features/login/login_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';

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
    final secao = context.watch<HomeController>().secao;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppEspacamentos.md,
        title: const AppMarcaCabecalho(),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => _sair(context),
          ),
        ],
      ),
      body: switch (secao) {
        SecaoPainel.inicio => const ResumoInicio(),
        SecaoPainel.filiais => const SecaoFiliais(),
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
