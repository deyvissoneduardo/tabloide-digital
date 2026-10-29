import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/src/features/home/plataforma/link_service_web.dart';
import 'package:tabloide_web/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Prévia nativa: espelha a ordem e a aparência em edição, sem salvar (D10,
/// T6).
class PreviaPagina extends StatelessWidget {
  const PreviaPagina({super.key, required this.dados});

  final DadosPagina dados;

  Future<void> _abrirPdf(BuildContext context, String url) async {
    final abriu = await context.read<LinkServiceWeb>().abrir(url);
    if (abriu || !context.mounted) return;
    mostrarAviso(context, 'Não conseguimos abrir o PDF.', tipo: TipoAviso.erro);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaginaController>();
    final aparencia = controller.aparenciaEmEdicao;
    final panfleto = dados.panfletoVigente;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppEspacamentos.md),
      child: AppPreviaPagina(
        dados: dados,
        categorias: controller.emEdicao,
        configuracao: aparencia.configuracao,
        bytesLogoBanner: aparencia.bytesLogo,
        bytesFotoBanner: aparencia.bytesFoto,
        aoAbrirPdf: panfleto == null
            ? null
            : () => _abrirPdf(context, panfleto.urlArquivo),
      ),
    );
  }
}
