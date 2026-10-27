import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/home/paginas_publicadas_controller.dart';
import 'package:tabloide_app/src/features/home/paginas_publicadas_estado.dart';
import 'package:tabloide_app/src/features/home/plataforma/link_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// "Suas páginas": um card por filial, na ordem da lista de filiais (D14).
class SecaoPaginasPublicadas extends StatefulWidget {
  const SecaoPaginasPublicadas({super.key, required this.resumo});

  final ResumoPainel resumo;

  @override
  State<SecaoPaginasPublicadas> createState() => _SecaoPaginasPublicadasState();
}

class _SecaoPaginasPublicadasState extends State<SecaoPaginasPublicadas> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregar();
    });
  }

  Future<void> _carregar() =>
      context.read<PaginasPublicadasController>().carregar();

  Future<void> _abrir(String url) async {
    final abriu = await context.read<LinkServiceApp>().abrir(url);
    if (abriu || !mounted) return;
    mostrarAviso(
      context,
      'Não conseguimos abrir a página.',
      tipo: TipoAviso.erro,
    );
  }

  Future<void> _copiar(String url) async {
    await context.read<LinkServiceApp>().copiar(url);
    if (!mounted) return;
    mostrarAviso(context, 'Link copiado');
  }

  Future<void> _compartilhar(String texto, String url) async {
    final ResultadoCompartilhar resultado;
    try {
      resultado = await context.read<LinkServiceApp>().compartilhar(texto, url);
    } on Exception {
      if (!mounted) return;
      mostrarAviso(
        context,
        'Não conseguimos compartilhar o link.',
        tipo: TipoAviso.erro,
      );
      return;
    }
    if (resultado == ResultadoCompartilhar.copiado && mounted) {
      mostrarAviso(context, 'Link copiado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controller = context.watch<PaginasPublicadasController>();
    final filiais = context.watch<FiliaisController>().filiais;
    final titulo = Padding(
      padding: const EdgeInsets.only(
        top: AppEspacamentos.lg,
        bottom: AppEspacamentos.sm,
      ),
      child: Text('Suas páginas', style: tema.textTheme.titleMedium),
    );
    return switch (controller.estado) {
      PaginasCarregando() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titulo,
          const Esqueleto(altura: AppLayout.ladoQrCode),
        ],
      ),
      PaginasComFalha(:final falha) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titulo,
          EstadoFalha(mensagem: falha.mensagem, aoTentarDeNovo: _carregar),
        ],
      ),
      PaginasCarregadas(:final contexto) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titulo,
          for (final filial in filiais)
            Builder(
              builder: (context) {
                if (!controller.qrCodes.containsKey(filial.id) &&
                    !controller.qrCodesComFalha.contains(filial.id)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) controller.carregarQrCode(filial.id);
                  });
                }
                final resumo = widget.resumo.daFilial(filial.id);
                final url = filial.urlPublica;
                return AppCartaoPaginaFilial(
                  key: ValueKey(filial.id),
                  nomeFilial: filial.nome,
                  urlPublica: url,
                  situacao: controller.situacaoDe(resumo),
                  produtosNoAr: resumo?.produtosVigentes ?? 0,
                  contaAtiva: contexto.contaAtiva,
                  qrCode: controller.qrCodes[filial.id],
                  qrCodeFalhou: controller.qrCodesComFalha.contains(filial.id),
                  aoAbrir: () => _abrir(url),
                  aoCopiar: () => _copiar(url),
                  aoCompartilhar: () => _compartilhar(
                    'Confira as ofertas de ${contexto.nomeFantasia} - '
                    '${filial.nome}: $url',
                    url,
                  ),
                );
              },
            ),
        ],
      ),
    };
  }
}
