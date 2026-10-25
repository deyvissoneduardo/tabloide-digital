import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/escolher_filial_screen.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/filiais/filiais_estado.dart';
import 'package:tabloide_app/src/features/filiais/filial_form_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';

class SecaoFiliais extends StatelessWidget {
  const SecaoFiliais({super.key});

  Future<void> _abrirFormulario(
    BuildContext context, {
    FilialResponse? filial,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => FilialFormScreen(filial: filial)),
  );

  Future<void> _agir(
    BuildContext context,
    FilialResponse filial,
    AcaoFilial acao,
  ) async {
    final controller = context.read<FiliaisController>();
    switch (acao) {
      case AcaoFilial.usar:
        controller.usar(filial);
        mostrarAviso(context, 'Agora você está na filial ${filial.nome}.');
      case AcaoFilial.editar:
        await _abrirFormulario(context, filial: filial);
      case AcaoFilial.excluir:
        await _excluir(context, controller, filial);
    }
  }

  Future<void> _excluir(
    BuildContext context,
    FiliaisController controller,
    FilialResponse filial,
  ) async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir a filial ${filial.nome}?',
      mensagem: 'Panfleto, categorias e produtos desta filial também serão excluídos.',
      rotuloConfirmar: 'Excluir filial',
    );
    if (!confirmou || !context.mounted) return;
    final resultado = await controller.excluir(filial);
    if (!context.mounted) return;
    switch (resultado) {
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case Success():
        mostrarAviso(context, 'Filial excluída.');
        if (controller.emUso == null) {
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => const EscolherFilialScreen(),
            ),
            (_) => false,
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FiliaisController>();
    return switch (controller.estado) {
      FiliaisCarregando() => const EsqueletoLista(),
      FiliaisComFalha(:final falha) => EstadoFalha(
        mensagem: falha.mensagem,
        aoTentarDeNovo: controller.carregar,
      ),
      FiliaisCarregadas(:final filiais) => ListView(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        children: [
          AppBotaoPrincipal(
            rotulo: 'Nova filial',
            aoPressionar: () => _abrirFormulario(context),
          ),
          const SizedBox(height: AppEspacamentos.md),
          for (final filial in filiais)
            AppCartaoFilial(
              filial: filial,
              emUso: filial.id == controller.emUso?.id,
              podeExcluir: controller.podeExcluir,
              aoEscolherAcao: (acao) => _agir(context, filial, acao),
            ),
        ],
      ),
    };
  }
}
