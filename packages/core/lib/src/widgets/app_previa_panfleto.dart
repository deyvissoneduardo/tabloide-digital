import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/panfletos/models/tipo_arquivo_panfleto.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

/// Panfleto na prévia, igual ao da página pública: cartão branco com sombra,
/// validade em etiqueta e "Abrir PDF" na primária. O Flutter não desenha o
/// PDF: mostra o arquivo no cartão (D13).
class AppPreviaPanfleto extends StatelessWidget {
  const AppPreviaPanfleto({
    super.key,
    required this.panfleto,
    required this.cores,
    this.aoAbrirPdf,
  });

  final PanfletoResponse panfleto;

  final AppCoresPagina cores;

  final VoidCallback? aoAbrirPdf;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final quebrada = Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: AppIcones.destaque,
        color: esquema.onSurfaceVariant,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(
        left: AppEspacamentos.md,
        top: AppEspacamentos.md,
        right: AppEspacamentos.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppEspacamentos.sm + AppEspacamentos.xs,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: esquema.surface,
              borderRadius: AppRaios.bordaLg,
              boxShadow: AppCoresPagina.sombraPanfleto,
            ),
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
              TipoArquivoPanfleto.pdf => Padding(
                padding: const EdgeInsets.all(AppEspacamentos.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      size: AppIcones.destaque,
                      color: cores.primaria,
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
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            },
          ),
          if (panfleto.vigencia.dataLimite case final limite?)
            DecoratedBox(
              decoration: BoxDecoration(
                color: esquema.surface,
                borderRadius: AppRaios.bordaPilula,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppEspacamentos.md,
                  vertical: AppEspacamentos.xs,
                ),
                child: Text(
                  'Válido até ${DataDia.curta(limite)}',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: cores.secundaria,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (panfleto.tipo == TipoArquivoPanfleto.pdf)
            FilledButton(
              onPressed: aoAbrirPdf,
              style: FilledButton.styleFrom(
                backgroundColor: cores.primaria,
                foregroundColor: AppCoresPagina.sobreCor,
              ),
              child: const Text('Abrir PDF'),
            ),
        ],
      ),
    );
  }
}
