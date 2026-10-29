import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/estrutura/models/dados_pagina.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';
import 'package:tabloide_core/src/widgets/app_previa_banner.dart';
import 'package:tabloide_core/src/widgets/app_previa_cabecalho.dart';
import 'package:tabloide_core/src/widgets/app_previa_categoria.dart';
import 'package:tabloide_core/src/widgets/app_previa_grade_produtos.dart';
import 'package:tabloide_core/src/widgets/app_previa_panfleto.dart';

/// Prévia nativa da página pública (plano.md §4.4 e §4.6), referência visual
/// da página React. Mostra a ordem recebida em [categorias] e a aparência em
/// [configuracao] (as duas em edição) e esconde categorias sem produtos
/// (RN41). Topo: banner se ligado e sem panfleto em exibição (U8), senão o
/// cabeçalho.
class AppPreviaPagina extends StatelessWidget {
  const AppPreviaPagina({
    super.key,
    required this.dados,
    required this.categorias,
    this.configuracao,
    this.bytesLogoBanner,
    this.bytesFotoBanner,
    this.aoAbrirPdf,
  });

  final DadosPagina dados;

  final List<CategoriaEstruturaResponse> categorias;

  /// Aparência em edição; `null` usa a salva em [dados].
  final ConfiguracaoPaginaResponse? configuracao;

  /// Logo do banner escolhido e ainda não publicado (T6).
  final Uint8List? bytesLogoBanner;

  /// Foto da campanha escolhida e ainda não publicada (T6).
  final Uint8List? bytesFotoBanner;

  final VoidCallback? aoAbrirPdf;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final configuracao = this.configuracao ?? dados.configuracao;
    final cores = AppCoresPagina.de(configuracao.cores);
    final comProdutos = [
      for (final categoria in categorias)
        if (categoria.produtos.isNotEmpty) categoria,
    ];
    final panfleto = dados.panfletoVigente;
    final exibePanfleto = dados.exibePanfleto && panfleto != null;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.larguraPrevia),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cores.fundoPagina,
            border: Border.all(color: tema.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppEspacamentos.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!exibePanfleto && configuracao.banner.exibir)
                  AppPreviaBanner(
                    banner: configuracao.banner,
                    cores: cores,
                    bytesLogo: bytesLogoBanner,
                    bytesFoto: bytesFotoBanner,
                  )
                else
                  AppPreviaCabecalho(
                    identidade: dados.identidade,
                    cores: cores,
                  ),
                if (exibePanfleto)
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
                      color: cores.fundoCartao,
                      borderRadius: AppRaios.bordaLg,
                    ),
                    child: Text(
                      'Nenhuma oferta no momento.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyLarge?.copyWith(
                        color: cores.texto,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (!configuracao.exibirNomeCategoria)
                  AppPreviaGradeProdutos(categorias: comProdutos, cores: cores)
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
