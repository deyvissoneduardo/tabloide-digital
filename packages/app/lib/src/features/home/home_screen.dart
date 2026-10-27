import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/widgets/secao_filiais.dart';
import 'package:tabloide_app/src/features/home/widgets/resumo_inicio.dart';
import 'package:tabloide_app/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_app/src/features/pagina/widgets/secao_pagina.dart';
import 'package:tabloide_app/src/features/panfletos/widgets/secao_panfletos.dart';
import 'package:tabloide_app/src/features/perfil/perfil_screen.dart';
import 'package:tabloide_app/src/features/produtos/widgets/secao_produtos.dart';
import 'package:tabloide_core/tabloide_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// D11: sair da seção Página com a ordem não publicada pede confirmação.
  /// `true` = pode sair (sem mudanças ou descartadas).
  Future<bool> _podeSairDaPagina(BuildContext context) async {
    final home = context.read<HomeController>();
    final pagina = context.read<PaginaController>();
    if (home.secao != SecaoPainel.pagina || !pagina.temMudancas) return true;
    final descartar = await confirmar(
      context,
      titulo: 'Descartar as mudanças?',
      mensagem: 'A nova ordem ainda não foi publicada.',
      rotuloConfirmar: 'Descartar',
      rotuloCancelar: 'Continuar editando',
    );
    if (descartar) pagina.descartar();
    return descartar;
  }

  Future<void> _selecionar(BuildContext context, SecaoPainel destino) async {
    final home = context.read<HomeController>();
    if (destino != SecaoPainel.pagina && !await _podeSairDaPagina(context)) {
      return;
    }
    home.selecionar(destino);
  }

  Future<void> _abrirPerfil(BuildContext context) async {
    final navegador = Navigator.of(context);
    if (!await _podeSairDaPagina(context)) return;
    await navegador.push(
      MaterialPageRoute<void>(builder: (_) => const PerfilScreen()),
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
        SecaoPainel.produtos => const SecaoProdutos(),
        SecaoPainel.pagina => const SecaoPagina(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: secao.index,
        onDestinationSelected: (i) =>
            _selecionar(context, SecaoPainel.values[i]),
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
