import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

class AppLogoIdentidade extends StatelessWidget {
  const AppLogoIdentidade({
    super.key,
    required this.url,
    required this.nome,
    this.tamanho = 96,
  });

  final String? url;
  final String nome;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final semLogo = Icon(
      Icons.add_photo_alternate_outlined,
      size: AppIcones.destaque,
      color: cores.onSurfaceVariant,
    );
    return Semantics(
      label: url == null ? 'Sem logo' : 'Logo de $nome',
      image: true,
      child: Container(
        width: tamanho,
        height: tamanho,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cores.surfaceContainerHighest,
          borderRadius: AppRaios.bordaMd,
          border: Border.all(color: cores.outlineVariant),
        ),
        child: switch (url) {
          final url? => Image.network(
            url,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
            errorBuilder: (context, _, _) => Icon(
              Icons.broken_image_outlined,
              size: AppIcones.destaque,
              color: cores.onSurfaceVariant,
            ),
          ),
          null => semLogo,
        },
      ),
    );
  }
}
