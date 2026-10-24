import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/widgets/marca_logo.dart';
import 'package:tabloide_core/src/widgets/marca_nome.dart';

class AppMarcaDestaque extends StatelessWidget {
  const AppMarcaDestaque({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      MarcaLogo(altura: AppIcones.destaque),
      SizedBox(height: AppEspacamentos.sm),
      MarcaNome(),
    ],
  );
}
