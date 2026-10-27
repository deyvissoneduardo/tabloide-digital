import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/estrutura/models/dados_pagina.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';
import 'package:tabloide_core/src/widgets/app_previa_cabecalho.dart';
import 'package:tabloide_core/src/widgets/app_previa_categoria.dart';
import 'package:tabloide_core/src/widgets/app_previa_panfleto.dart';

/// Prévia nativa da página pública (plano §4.7 e §4.8). Mostra a ordem
/// recebida em [categorias] (a que está em edição) e esconde categorias sem
/// produtos (RN41, T7).
class AppPreviaPagina extends StatelessWidget {
  const AppPreviaPagina({
    super.key,
    required this.dados,
    required this.categorias,
    this.aoAbrirPdf,
  });

  final DadosPagina dados;

  final List<CategoriaEstruturaResponse> categorias;

  final VoidCallback? aoAbrirPdf;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final identidade = dados.identidade;
    final cores = AppCoresPagina.de(
      corPrimaria: identidade.corPrimaria,
      corSecundaria: identidade.corSecundaria,
    );
    final comProdutos = [
      for (final categoria in categorias)
        if (categoria.produtos.isNotEmpty) categoria,
    ];
    final panfleto = dados.panfletoVigente;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.larguraPrevia),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppCoresPagina.fundo,
            border: Border.all(color: tema.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppEspacamentos.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppPreviaCabecalho(identidade: identidade, cores: cores),
                if (dados.exibePanfleto && panfleto != null)
                  AppPreviaPanfleto(
                    panfleto: panfleto,
                    cores: cores,
                    aoAbrirPdf: aoAbrirPdf,
                  )
                else if (comProdutos.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(
                      left: AppEspacamentos.md,
                      top: AppEspacamentos.lg,
                      right: AppEspacamentos.md,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppEspacamentos.md,
                      vertical: AppEspacamentos.xl + AppEspacamentos.sm,
                    ),
                    decoration: BoxDecoration(
                      color: tema.colorScheme.surface,
                      borderRadius: AppRaios.bordaLg,
                    ),
                    child: Text(
                      'Nenhuma oferta no momento.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyLarge?.copyWith(
                        color: tema.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  for (final categoria in comProdutos)
                    AppPreviaCategoria(categoria: categoria, cores: cores),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
