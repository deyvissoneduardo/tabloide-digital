import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/widgets/app_previa_produto.dart';

/// Categoria da prévia, igual à da página pública: nome na cor `categoria`
/// com barra na secundária, total de ofertas e produtos na horizontal.
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
    final total = categoria.produtos.length;
    return Padding(
      padding: const EdgeInsets.only(
        top: AppEspacamentos.md + AppEspacamentos.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspacamentos.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: cores.secundaria,
                          width: AppEspacamentos.xs,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppEspacamentos.sm),
                      child: Text(
                        categoria.nome,
                        style: tema.textTheme.titleLarge?.copyWith(
                          color: cores.categoria,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppEspacamentos.sm),
                Text(
                  total == 1 ? '1 oferta' : '$total ofertas',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: cores.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppEspacamentos.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppEspacamentos.md,
              AppEspacamentos.xs,
              AppEspacamentos.md,
              AppEspacamentos.md,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, produto) in categoria.produtos.indexed) ...[
                    if (i > 0)
                      const SizedBox(
                        width: AppEspacamentos.sm + AppEspacamentos.xs,
                      ),
                    AppPreviaProduto(produto: produto, cores: cores),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
