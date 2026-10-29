import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/produtos/models/centavos.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

/// Cartão de produto da prévia: igual ao da página pública (cartão
/// `fundoCartao` com sombra, selo de desconto, preço em destaque, observação e validade em
/// etiquetas). Agendado não tem selo nem diferença visual (D10).
class AppPreviaProduto extends StatelessWidget {
  const AppPreviaProduto({
    super.key,
    required this.produto,
    required this.cores,
    this.largura = AppLayout.larguraCartaoProdutoPrevia,
  });

  final ProdutoEstruturaResponse produto;

  final AppCoresPagina cores;

  /// Largura do cartão: a do carrossel; `null` ocupa a coluna da grade.
  final double? largura;

  /// Desconto inteiro de "de/por" (RN32), igual à página pública; `null`
  /// quando não há preço original maior.
  static int? percentualDesconto(int promocional, int? original) {
    if (original == null || original <= promocional) return null;
    final percentual = ((1 - promocional / original) * 100).round();
    return percentual > 0 ? percentual : null;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final texto = tema.textTheme;
    final suave = cores.textoSuave;
    final urlFoto = produto.urlFoto;
    final desconto = percentualDesconto(
      produto.precoPromocionalCentavos,
      produto.precoOriginalCentavos,
    );
    final semFoto = ColoredBox(
      color: cores.neutra,
      child: Center(
        child: Icon(Icons.sell, size: AppIcones.destaque, color: suave),
      ),
    );
    final etiqueta = texto.labelSmall?.copyWith(fontWeight: FontWeight.w600);
    const recuoEtiqueta = EdgeInsets.symmetric(
      horizontal: AppEspacamentos.sm,
      vertical: AppEspacamentos.xs / 2,
    );
    return Container(
      width: largura,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cores.fundoCartao,
        borderRadius: AppRaios.bordaLg,
        boxShadow: AppCoresPagina.sombraCartao,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (urlFoto == null)
                  semFoto
                else
                  Image.network(
                    urlFoto,
                    fit: BoxFit.cover,
                    semanticLabel: 'Foto de ${produto.nome}',
                    errorBuilder: (_, _, _) => semFoto,
                  ),
                if (desconto != null)
                  Positioned(
                    top: AppEspacamentos.sm,
                    left: AppEspacamentos.sm,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cores.secundaria,
                        borderRadius: AppRaios.bordaPilula,
                      ),
                      child: Padding(
                        padding: recuoEtiqueta,
                        child: Text(
                          '-$desconto%',
                          style: texto.labelMedium?.copyWith(
                            color: cores.sobreCor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppEspacamentos.sm + AppEspacamentos.xs,
              AppEspacamentos.sm,
              AppEspacamentos.sm + AppEspacamentos.xs,
              AppEspacamentos.sm + AppEspacamentos.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: AppEspacamentos.xs,
              children: [
                Text(
                  produto.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: texto.titleSmall?.copyWith(
                    color: cores.primaria,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (produto.quantidade case final quantidade?)
                  Text(
                    quantidade,
                    style: texto.labelSmall?.copyWith(color: suave),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (produto.precoOriginalCentavos case final original?)
                      Text(
                        'de ${Centavos.formatar(original)}',
                        style: texto.bodySmall?.copyWith(
                          color: suave,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: suave,
                        ),
                      ),
                    Text(
                      Centavos.formatar(produto.precoPromocionalCentavos),
                      style: texto.titleLarge?.copyWith(
                        color: cores.primaria,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (produto.descricao case final descricao?)
                  Text(
                    descricao,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: texto.bodySmall?.copyWith(color: cores.secundaria),
                  ),
                if (produto.observacao case final observacao?)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: cores.secundaria),
                      borderRadius: AppRaios.bordaSm,
                    ),
                    child: Padding(
                      padding: recuoEtiqueta,
                      child: Text(
                        observacao,
                        style: etiqueta?.copyWith(color: cores.secundaria),
                      ),
                    ),
                  ),
                if (produto.vigencia.dataLimite case final limite?)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cores.neutra,
                      borderRadius: AppRaios.bordaSm,
                    ),
                    child: Padding(
                      padding: recuoEtiqueta,
                      child: Text(
                        'válido até ${DataDia.curta(limite)}',
                        style: etiqueta?.copyWith(color: cores.texto),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
