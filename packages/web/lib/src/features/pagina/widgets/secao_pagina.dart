import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_web/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_web/src/features/pagina/pagina_estado.dart';
import 'package:tabloide_web/src/features/pagina/widgets/botao_publicar_ordem.dart';
import 'package:tabloide_web/src/features/pagina/widgets/editor_pagina.dart';
import 'package:tabloide_web/src/features/pagina/widgets/previa_pagina.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Seção "Página": montar a ordem e ver a prévia. Na web, lado a lado a
/// partir de 840 px (expandido); abaixo disso, em abas "Montar" / "Prévia"
/// (D12).
class SecaoPagina extends StatefulWidget {
  const SecaoPagina({super.key});

  @override
  State<SecaoPagina> createState() => _SecaoPaginaState();
}

class _SecaoPaginaState extends State<SecaoPagina> {
  String? _filialPedida;

  Future<void> _carregar(String filialId) {
    _filialPedida = filialId;
    return context.read<PaginaController>().carregar(filialId);
  }

  Future<void> _aoVoltar(bool saiu, Object? _) async {
    if (saiu) return;
    final controller = context.read<PaginaController>();
    final descartar = await confirmar(
      context,
      titulo: 'Descartar as mudanças?',
      mensagem: 'A nova ordem ainda não foi publicada.',
      rotuloConfirmar: 'Descartar',
      rotuloCancelar: 'Continuar editando',
    );
    if (descartar) controller.descartar();
  }

  @override
  Widget build(BuildContext context) {
    final filial = context.watch<FiliaisController>().emUso;
    final controller = context.watch<PaginaController>();
    if (filial != null && filial.id != _filialPedida) {
      _filialPedida = filial.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _carregar(filial.id);
      });
    }
    final conteudo = switch (controller.estado) {
      _ when filial == null || controller.filialId != filial.id =>
        const EsqueletoLista(),
      PaginaCarregando() => const EsqueletoLista(),
      PaginaComFalha(:final falha) => EstadoFalha(
        mensagem: falha.mensagem,
        aoTentarDeNovo: () => _carregar(filial.id),
      ),
      PaginaCarregada(:final dados) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppEspacamentos.md,
              top: AppEspacamentos.md,
              right: AppEspacamentos.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.bloqueado)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppEspacamentos.md),
                      child: AppAviso(
                        tipo: TipoAviso.alerta,
                        mensagem:
                            'Conta desativada: a ordem não pode ser alterada.',
                      ),
                    ),
                  ),
                const BotaoPublicarOrdem(),
              ],
            ),
          ),
          Expanded(
            child: ClasseTamanho.de(context) == ClasseTamanho.expandido
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: EditorPagina(exibePanfleto: dados.exibePanfleto),
                      ),
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: AppLayout.larguraPrevia,
                        child: PreviaPagina(dados: dados),
                      ),
                    ],
                  )
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Montar'),
                            Tab(text: 'Prévia'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              EditorPagina(exibePanfleto: dados.exibePanfleto),
                              PreviaPagina(dados: dados),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    };
    return PopScope(
      canPop: !controller.temMudancas,
      onPopInvokedWithResult: _aoVoltar,
      child: conteudo,
    );
  }
}
