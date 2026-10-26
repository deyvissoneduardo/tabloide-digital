import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_marca.dart';

class MarcaLogo extends StatelessWidget {
  const MarcaLogo({super.key, this.altura = 32});

  final double altura;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AppMarca.logo,
      height: altura,
      semanticLabel: 'Logo de ${AppMarca.nome}',
      errorBuilder: (context, _, _) =>
          _Iniciais(nome: AppMarca.nome, altura: altura),
    );
  }
}

class _Iniciais extends StatelessWidget {
  const _Iniciais({required this.nome, required this.altura});

  final String nome;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final iniciais = nome
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Semantics(
      label: 'Logo de $nome',
      excludeSemantics: true,
      child: CircleAvatar(
        radius: altura / 2,
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
        child: Text(iniciais, style: TextStyle(fontSize: altura * 0.4)),
      ),
    );
  }
}
