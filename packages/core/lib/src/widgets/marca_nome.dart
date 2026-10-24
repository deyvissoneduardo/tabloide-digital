import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/src/brand/brand_config.dart';

class MarcaNome extends StatelessWidget {
  const MarcaNome({super.key, this.estilo});

  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.read<BrandConfig>().nome,
      style: estilo ?? Theme.of(context).textTheme.titleLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
