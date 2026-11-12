import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/utils/formatar_numero.dart';

class AppIndicadorNumero extends StatelessWidget {
  const AppIndicadorNumero({
    super.key,
    required this.rotulo,
    required this.valor,
    this.apoio,
  });

  final String rotulo;

  final int valor;

  final String? apoio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo, style: tema.textTheme.titleSmall),
            const SizedBox(height: AppEspacamentos.xs),
            Text(
              formatarInteiro(valor),
              style: tema.textTheme.headlineSmall?.copyWith(
                color: tema.colorScheme.primary,
              ),
            ),
            if (apoio case final apoio?) Text(apoio, style: suave),
          ],
        ),
      ),
    );
  }
}
