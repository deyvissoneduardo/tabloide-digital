import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/widgets/app_previa_produto.dart';

/// Categoria da prévia: nome na primária e produtos na horizontal.
class AppPreviaCategoria extends StatelessWidget {
  const AppPreviaCategoria({
    super.key,
    required this.categoria,
    required this.cores,
  });

  final CategoriaEstruturaResponse categoria;

  final AppCoresPagina cores;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppEspacamentos.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspacamentos.md),
            child: Text(
              categoria.nome,
              style: tema.textTheme.titleMedium?.copyWith(
                color: cores.primaria,
              ),
            ),
          ),
          const SizedBox(height: AppEspacamentos.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppEspacamentos.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, produto) in categoria.produtos.indexed) ...[
                  if (i > 0) const SizedBox(width: AppEspacamentos.sm),
                  AppPreviaProduto(produto: produto, cores: cores),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
