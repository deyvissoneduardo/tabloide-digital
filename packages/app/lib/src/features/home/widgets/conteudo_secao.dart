import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Placeholder da seção até as features existirem.
class ConteudoSecao extends StatelessWidget {
  const ConteudoSecao({super.key, required this.secao});

  final SecaoPainel secao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacamentos.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              secao.iconeSelecionado,
              size: 64,
              color: tema.colorScheme.primary,
            ),
            const SizedBox(height: AppEspacamentos.md),
            Text(secao.titulo, style: tema.textTheme.headlineSmall),
            const SizedBox(height: AppEspacamentos.sm),
            Text(
              'Em breve',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
