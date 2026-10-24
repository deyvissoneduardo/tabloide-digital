import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

class Esqueleto extends StatelessWidget {
  const Esqueleto({super.key, required this.altura, this.largura});

  final double altura;

  final double? largura;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Carregando',
    child: Container(
      height: altura,
      width: largura ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRaios.bordaMd,
      ),
    ),
  );
}

class EsqueletoLista extends StatelessWidget {
  const EsqueletoLista({super.key, this.quantidade = 3, this.altura = 72});

  final int quantidade;

  final double altura;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: quantidade,
    separatorBuilder: (_, _) => const SizedBox(height: AppEspacamentos.sm),
    itemBuilder: (_, _) => Esqueleto(altura: altura),
  );
}
