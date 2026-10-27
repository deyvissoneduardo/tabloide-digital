import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/produtos/models/centavos.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_cores_pagina.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';

/// Cartão de produto da prévia: igual ao da página pública. Agendado não tem
/// selo nem diferença visual (D10).
class AppPreviaProduto extends StatelessWidget {
  const AppPreviaProduto({
    super.key,
    required this.produto,
    required this.cores,
  });

  final ProdutoEstruturaResponse produto;

  final AppCoresPagina cores;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final texto = tema.textTheme;
    final urlFoto = produto.urlFoto;
    final semFoto = Center(
      child: Icon(
        Icons.sell_outlined,
        size: AppIcones.destaque,
        color: tema.colorScheme.onSurfaceVariant,
      ),
    );
    final secundario = texto.bodySmall?.copyWith(color: cores.secundaria);
    return SizedBox(
      width: AppLayout.larguraCartaoProdutoPrevia,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(
                color: tema.colorScheme.surfaceContainerHighest,
                child: urlFoto == null
                    ? semFoto
                    : Image.network(
                        urlFoto,
                        fit: BoxFit.cover,
                        semanticLabel: 'Foto de ${produto.nome}',
                        errorBuilder: (_, _, _) => semFoto,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppEspacamentos.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    produto.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: texto.titleSmall?.copyWith(color: cores.primaria),
                  ),
                  if (produto.quantidade case final quantidade?)
                    Text(quantidade, style: secundario),
                  if (produto.descricao case final descricao?)
                    Text(
                      descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: secundario,
                    ),
                  const SizedBox(height: AppEspacamentos.xs),
                  if (produto.precoOriginalCentavos case final original?)
                    Text(
                      'de ${Centavos.formatar(original)}',
                      style: secundario?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: cores.secundaria,
                      ),
                    ),
                  Text(
                    Centavos.formatar(produto.precoPromocionalCentavos),
                    style: texto.titleLarge?.copyWith(color: cores.primaria),
                  ),
                  if (produto.observacao case final observacao?)
                    Text(observacao, style: secundario),
                  if (produto.vigencia.dataLimite case final limite?)
                    Text(
                      'válido até ${DataDia.curta(limite)}',
                      style: secundario,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
