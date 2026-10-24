import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/widgets/marca_logo.dart';
import 'package:tabloide_core/src/widgets/marca_nome.dart';

class AppMarcaCabecalho extends StatelessWidget {
  const AppMarcaCabecalho({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      MarcaLogo(),
      SizedBox(width: AppEspacamentos.sm),
      Flexible(child: MarcaNome()),
    ],
  );
}
