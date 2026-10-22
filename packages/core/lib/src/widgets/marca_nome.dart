import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/src/brand/brand_config.dart';

/// Nome da marca ativa, cortado com reticências se não couber.
class MarcaNome extends StatelessWidget {
  /// Cria o texto com o [estilo] informado (padrão: `titleLarge`).
  const MarcaNome({super.key, this.estilo});

  /// Estilo do texto.
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) => Text(
    context.read<BrandConfig>().nome,
    style: estilo ?? Theme.of(context).textTheme.titleLarge,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
