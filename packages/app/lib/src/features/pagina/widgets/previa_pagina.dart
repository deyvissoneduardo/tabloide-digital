import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/home/plataforma/link_service_app.dart';
import 'package:tabloide_app/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Prévia nativa: espelha a ordem em edição, sem salvar (D10).
class PreviaPagina extends StatelessWidget {
  const PreviaPagina({super.key, required this.dados});

  final DadosPagina dados;

  Future<void> _abrirPdf(BuildContext context, String url) async {
    final abriu = await context.read<LinkServiceApp>().abrir(url);
    if (abriu || !context.mounted) return;
    mostrarAviso(context, 'Não conseguimos abrir o PDF.', tipo: TipoAviso.erro);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<PaginaController>().emEdicao;
    final panfleto = dados.panfletoVigente;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppEspacamentos.md),
      child: AppPreviaPagina(
        dados: dados,
        categorias: categorias,
        aoAbrirPdf: panfleto == null
            ? null
            : () => _abrirPdf(context, panfleto.urlArquivo),
      ),
    );
  }
}
