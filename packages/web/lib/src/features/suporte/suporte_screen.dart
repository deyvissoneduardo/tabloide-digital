import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

class SuporteScreen extends StatelessWidget {
  const SuporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Suporte')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.larguraMaximaFormulario,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppEspacamentos.md),
              children: [
                Text(
                  'Do cadastro à página no ar',
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: AppEspacamentos.xs),
                Text(
                  'Siga os tópicos na ordem. Toque em um deles para ver o passo a passo e as dicas.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppEspacamentos.md),
                for (final (i, topico) in guiaSuporte.indexed)
                  AppTopicoSuporte(topico: topico, numero: i + 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
