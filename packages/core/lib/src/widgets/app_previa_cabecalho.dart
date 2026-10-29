import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

/// Cabeçalho da prévia da página, igual ao da página pública: faixa na
/// primária, logo (ou iniciais) num bloco `sobreCor` e o nome do lojista.
/// Nunca mostra a filial (U9).
class AppPreviaCabecalho extends StatelessWidget {
  const AppPreviaCabecalho({
    super.key,
    required this.identidade,
    required this.cores,
  });

  final IdentidadeResponse identidade;

  final AppCoresPagina cores;

  /// Até 2 letras: primeira e última palavra do nome (igual à página pública).
  static String iniciais(String nome) {
    final palavras = nome.trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (palavras.isEmpty) return '';
    final primeira = palavras.first[0];
    final ultima = palavras.length > 1 ? palavras.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final urlLogo = identidade.urlLogo;
    final siglas = Text(
      iniciais(identidade.nomeFantasia),
      style: texto.titleLarge?.copyWith(
        color: cores.primaria,
        fontWeight: FontWeight.w800,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.primaria,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRaios.xl),
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppCoresPagina.brilhoCabecalho,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppRaios.xl),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppEspacamentos.md,
            AppEspacamentos.md + AppEspacamentos.xs,
            AppEspacamentos.md,
            AppEspacamentos.lg + AppEspacamentos.xs,
          ),
          child: Row(
            children: [
              Container(
                width: AppLayout.ladoLogoPrevia,
                height: AppLayout.ladoLogoPrevia,
                padding: const EdgeInsets.all(AppEspacamentos.xs),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cores.sobreCor,
                  borderRadius: AppRaios.bordaLg,
                  boxShadow: AppCoresPagina.sombraLogo,
                ),
                child: urlLogo == null
                    ? siglas
                    : Image.network(
                        urlLogo,
                        fit: BoxFit.contain,
                        semanticLabel: 'Logo de ${identidade.nomeFantasia}',
                        errorBuilder: (_, _, _) => Icon(
                          Icons.storefront_outlined,
                          size: AppIcones.padrao,
                          color: cores.primaria,
                        ),
                      ),
              ),
              const SizedBox(width: AppEspacamentos.md),
              Expanded(
                child: Text(
                  identidade.nomeFantasia,
                  style: texto.titleLarge?.copyWith(
                    color: cores.sobreCor,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
