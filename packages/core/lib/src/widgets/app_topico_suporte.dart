import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/suporte/guia_suporte.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

class AppTopicoSuporte extends StatelessWidget {
  const AppTopicoSuporte({
    super.key,
    required this.topico,
    required this.numero,
    this.inicialmenteAberto = false,
  });

  final TopicoSuporte topico;

  final int numero;

  final bool inicialmenteAberto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: inicialmenteAberto,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: tema.colorScheme.primaryContainer,
          foregroundColor: tema.colorScheme.onPrimaryContainer,
          child: Icon(topico.icone, size: AppIcones.pequeno),
        ),
        title: Text(
          '$numero. ${topico.titulo}',
          style: tema.textTheme.titleMedium,
        ),
        subtitle: Text(
          topico.resumo,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        childrenPadding: const EdgeInsets.only(
          left: AppEspacamentos.md,
          right: AppEspacamentos.md,
          bottom: AppEspacamentos.md,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Passo a passo', style: tema.textTheme.titleSmall),
          const SizedBox(height: AppEspacamentos.sm),
          for (final (i, passo) in topico.passos.indexed)
            _Item(marcador: '${i + 1}.', texto: passo),
          if (topico.dicas.isNotEmpty) ...[
            const SizedBox(height: AppEspacamentos.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tema.colorScheme.surfaceContainerHigh,
                borderRadius: AppRaios.bordaMd,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppEspacamentos.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: AppIcones.pequeno,
                          color: tema.colorScheme.primary,
                        ),
                        const SizedBox(width: AppEspacamentos.sm),
                        Text(
                          'Dicas',
                          style: tema.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppEspacamentos.sm),
                    for (final dica in topico.dicas)
                      _Item(
                        marcador: '•',
                        texto: dica,
                        cor: tema.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.marcador, required this.texto, this.cor});

  final String marcador;
  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: cor,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppEspacamentos.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppEspacamentos.lg,
            child: Text(marcador, style: estilo),
          ),
          Expanded(child: Text(texto, style: estilo)),
        ],
      ),
    );
  }
}
