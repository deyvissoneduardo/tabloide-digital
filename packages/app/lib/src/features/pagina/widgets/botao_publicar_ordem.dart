import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// "Publicar ordem": ação principal da seção Página.
class BotaoPublicarOrdem extends StatelessWidget {
  const BotaoPublicarOrdem({super.key});

  Future<void> _publicar(BuildContext context) async {
    final resultado = await context.read<PaginaController>().publicar();
    if (!context.mounted) return;
    switch (resultado) {
      case Success():
        mostrarAviso(
          context,
          'Ordem publicada. A página atualiza em até 1 minuto.',
        );
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaginaController>();
    final habilitado = controller.temMudancas && !controller.bloqueado;
    return AppBotaoPrincipal(
      rotulo: 'Publicar ordem',
      rotuloCarregando: 'Publicando',
      carregando: controller.publicando,
      aoPressionar: habilitado ? () => _publicar(context) : null,
    );
  }
}
