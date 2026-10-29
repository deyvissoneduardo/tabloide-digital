import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

/// Banner da prévia (RN46, plano.md §4.6): substitui o cabeçalho. Mesmo
/// container do cabeçalho com fundo `fundoBanner`; linha [logo] [nome] (cada
/// um só se houver) e, abaixo, a foto 16:9 **ou** a descrição. Sem nada, é só
/// a faixa de cor. [bytesLogo]/[bytesFoto] são imagens escolhidas e ainda não
/// publicadas (T6) e vencem as URLs.
class AppPreviaBanner extends StatelessWidget {
  const AppPreviaBanner({
    super.key,
    required this.banner,
    required this.cores,
    this.bytesLogo,
    this.bytesFoto,
  });

  final BannerResponse banner;

  final AppCoresPagina cores;

  final Uint8List? bytesLogo;

  final Uint8List? bytesFoto;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final nome = banner.nome;
    final urlLogo = banner.urlLogo;
    final bytesLogo = this.bytesLogo;
    final bytesFoto = this.bytesFoto;
    final temLogo = bytesLogo != null || urlLogo != null;
    final logoQuebrado = Icon(
      Icons.broken_image_outlined,
      size: AppIcones.padrao,
      color: cores.fundoBanner,
    );
    final fotoQuebrada = Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: AppIcones.destaque,
        color: cores.sobreCor,
      ),
    );
    final urlFoto = switch (banner.campanha) {
      CampanhaFoto(:final urlFoto) => urlFoto,
      _ => null,
    };
    final descricao = switch (banner.campanha) {
      CampanhaDescricao(:final descricao) when bytesFoto == null => descricao,
      _ => null,
    };
    final temFoto = bytesFoto != null || urlFoto != null;
    final temLinha = temLogo || nome != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.fundoBanner,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: AppEspacamentos.md,
            children: [
              if (temLinha)
                Row(
                  spacing: AppEspacamentos.md,
                  children: [
                    if (temLogo)
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
                        child: switch ((bytesLogo, urlLogo)) {
                          (final bytes?, _) => Image.memory(
                            bytes,
                            fit: BoxFit.contain,
                            semanticLabel: 'Logo do banner',
                            errorBuilder: (_, _, _) => logoQuebrado,
                          ),
                          (null, final url?) => Image.network(
                            url,
                            fit: BoxFit.contain,
                            semanticLabel: 'Logo do banner',
                            errorBuilder: (_, _, _) => logoQuebrado,
                          ),
                          (null, null) => logoQuebrado,
                        },
                      ),
                    if (nome != null)
                      Expanded(
                        child: Text(
                          nome,
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
              if (temFoto)
                ClipRRect(
                  borderRadius: AppRaios.bordaLg,
                  child: AspectRatio(
                    aspectRatio: AppLayout.proporcaoFotoBanner,
                    child: switch ((bytesFoto, urlFoto)) {
                      (final bytes?, _) => Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        semanticLabel: 'Foto da campanha',
                        errorBuilder: (_, _, _) => fotoQuebrada,
                      ),
                      (null, final url?) => Image.network(
                        url,
                        fit: BoxFit.cover,
                        semanticLabel: 'Foto da campanha',
                        errorBuilder: (_, _, _) => fotoQuebrada,
                      ),
                      (null, null) => fotoQuebrada,
                    },
                  ),
                )
              else if (descricao != null)
                Text(
                  descricao,
                  style: texto.bodyMedium?.copyWith(color: cores.sobreCor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
