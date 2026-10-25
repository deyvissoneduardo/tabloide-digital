import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

class SeletorUf extends StatelessWidget {
  const SeletorUf({super.key, this.selecionada});

  final Uf? selecionada;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspacamentos.md),
            child: Text('Escolha a UF', style: tema.textTheme.titleMedium),
          ),
          const SizedBox(height: AppEspacamentos.sm),
          Expanded(
            child: ListView(
              children: [
                for (final uf in Uf.values)
                  ListTile(
                    title: Text('${uf.sigla} · ${uf.nome}'),
                    selected: uf == selecionada,
                    trailing: uf == selecionada
                        ? Icon(Icons.check, color: tema.colorScheme.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(uf),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
