import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_marca.dart';

class MarcaNome extends StatelessWidget {
  const MarcaNome({super.key, this.estilo});

  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppMarca.nome,
      style: estilo ?? Theme.of(context).textTheme.titleLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
