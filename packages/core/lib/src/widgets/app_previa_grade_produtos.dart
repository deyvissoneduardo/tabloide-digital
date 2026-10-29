import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/widgets/app_previa_produto.dart';

/// Grade única da prévia quando o nome da categoria está desligado (U10):
/// todos os produtos, na ordem categoria 1, categoria 2…, em
/// [AppLayout.colunasGradePrevia] colunas, sem título, contador nem barra.
/// Cartões da mesma linha têm a mesma altura.
class AppPreviaGradeProdutos extends StatelessWidget {
  const AppPreviaGradeProdutos({
    super.key,
    required this.categorias,
    required this.cores,
  });

  final List<CategoriaEstruturaResponse> categorias;

  final AppCoresPagina cores;

  @override
  Widget build(BuildContext context) {
    const colunas = AppLayout.colunasGradePrevia;
    const espaco = AppEspacamentos.sm + AppEspacamentos.xs;
    final produtos = [for (final c in categorias) ...c.produtos];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppEspacamentos.md,
        AppEspacamentos.md + AppEspacamentos.xs,
        AppEspacamentos.md,
        AppEspacamentos.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: espaco,
        children: [
          for (var inicio = 0; inicio < produtos.length; inicio += colunas)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaco,
                children: [
                  for (var i = inicio; i < inicio + colunas; i++)
                    Expanded(
                      child: i < produtos.length
                          ? AppPreviaProduto(
                              produto: produtos[i],
                              cores: cores,
                              largura: null,
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
