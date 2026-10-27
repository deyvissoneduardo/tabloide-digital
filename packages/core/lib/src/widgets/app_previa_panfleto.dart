import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/panfletos/models/tipo_arquivo_panfleto.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';

/// Panfleto na prévia: imagem inteira ou cartão de PDF com "Abrir PDF" (D13).
class AppPreviaPanfleto extends StatelessWidget {
  const AppPreviaPanfleto({super.key, required this.panfleto, this.aoAbrirPdf});

  final PanfletoResponse panfleto;

  final VoidCallback? aoAbrirPdf;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final quebrada = Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: AppIcones.destaque,
        color: cores.onSurfaceVariant,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppEspacamentos.md),
      child: switch (panfleto.tipo) {
        TipoArquivoPanfleto.imagem => AspectRatio(
          aspectRatio: panfleto.largura / panfleto.altura,
          child: Image.network(
            panfleto.urlArquivo,
            fit: BoxFit.contain,
            semanticLabel: 'Panfleto da filial',
            errorBuilder: (_, _, _) => quebrada,
          ),
        ),
        TipoArquivoPanfleto.pdf => Card(
          child: Padding(
            padding: const EdgeInsets.all(AppEspacamentos.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: AppIcones.destaque,
                  color: cores.primary,
                  semanticLabel: 'PDF',
                ),
                const SizedBox(height: AppEspacamentos.sm),
                Text(
                  panfleto.nomeArquivo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppEspacamentos.xs),
                Text(
                  'Panfleto em PDF de 1 página',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: cores.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppEspacamentos.md),
                OutlinedButton.icon(
                  onPressed: aoAbrirPdf,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir PDF'),
                ),
              ],
            ),
          ),
        ),
      },
    );
  }
}
