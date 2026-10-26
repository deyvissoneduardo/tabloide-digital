import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/panfletos/panfleto_form_screen.dart';
import 'package:tabloide_app/src/features/panfletos/panfletos_controller.dart';
import 'package:tabloide_app/src/features/panfletos/panfletos_estado.dart';
import 'package:tabloide_core/tabloide_core.dart';

class SecaoPanfletos extends StatefulWidget {
  const SecaoPanfletos({super.key});

  @override
  State<SecaoPanfletos> createState() => _SecaoPanfletosState();
}

class _SecaoPanfletosState extends State<SecaoPanfletos> {
  String? _filialPedida;

  @override
  void initState() {
    super.initState();
    _filialPedida = context.read<FiliaisController>().emUso?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final filial = context.read<FiliaisController>().emUso;
    if (filial == null) return;
    _filialPedida = filial.id;
    await context.read<PanfletosController>().carregar(filial.id);
  }

  Future<void> _abrirFormulario(
    FilialResponse filial, {
    PanfletoResponse? panfleto,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          PanfletoFormScreen(filialId: filial.id, panfleto: panfleto),
    ),
  );

  Future<void> _agir(
    FilialResponse filial,
    PanfletoResponse panfleto,
    AcaoPanfleto acao,
  ) async {
    switch (acao) {
      case AcaoPanfleto.editar:
        await _abrirFormulario(filial, panfleto: panfleto);
      case AcaoPanfleto.excluir:
        await _excluir(panfleto);
    }
  }

  Future<void> _excluir(PanfletoResponse panfleto) async {
    final controller = context.read<PanfletosController>();
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir este panfleto?',
      mensagem: 'Ele sai da página da filial na hora. Para publicar de novo, cadastre um novo panfleto.',
      rotuloConfirmar: 'Excluir panfleto',
    );
    if (!confirmou || !mounted) return;
    final resultado = await controller.excluir(panfleto);
    if (!mounted) return;
    switch (resultado) {
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case Success():
        mostrarAviso(context, 'Panfleto excluído.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filial = context.watch<FiliaisController>().emUso;
    final controller = context.watch<PanfletosController>();
    final tema = Theme.of(context);
    if (filial == null) {
      return const EstadoVazio(
        icone: Icons.storefront_outlined,
        titulo: 'Escolha uma filial',
        mensagem: 'Cada filial tem o próprio panfleto. Escolha a filial em uso na aba Filiais.',
      );
    }
    if (controller.filialId != filial.id) {
      if (_filialPedida != filial.id) {
        _filialPedida = filial.id;
        WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
      }
      return const EsqueletoLista();
    }
    return switch (controller.estado) {
      PanfletosCarregando() => const EsqueletoLista(),
      PanfletosComFalha(:final falha) => EstadoFalha(
        mensagem: falha.mensagem,
        aoTentarDeNovo: _carregar,
      ),
      PanfletosCarregados(:final panfletos) when panfletos.isEmpty =>
        EstadoVazio(
          icone: SecaoPainel.panfletos.iconeSelecionado,
          titulo: 'Nenhum panfleto na filial ${filial.nome}',
          mensagem: 'Publique a imagem do folheto para ela aparecer na página da filial.',
          rotuloAcao: 'Novo panfleto',
          aoAgir: () => _abrirFormulario(filial),
        ),
      PanfletosCarregados(:final panfletos) => ListView(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        children: [
          AppBotaoPrincipal(
            rotulo: 'Novo panfleto',
            aoPressionar: () => _abrirFormulario(filial),
          ),
          if (controller.atualSemDataLimite) ...[
            const SizedBox(height: AppEspacamentos.sm),
            Text(
              'Para agendar o próximo panfleto, defina antes a data limite do atual.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppEspacamentos.md),
          for (final panfleto in panfletos)
            AppCartaoPanfleto(
              panfleto: panfleto,
              aoTocar: panfleto.vigencia.editavel
                  ? () => _abrirFormulario(filial, panfleto: panfleto)
                  : null,
              aoEscolherAcao: (acao) => _agir(filial, panfleto, acao),
            ),
        ],
      ),
    };
  }
}
