import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:tabloide_core/src/features/produtos/models/centavos.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

const _moverParaEsquerda = CustomSemanticsAction(
  label: 'Mover para a esquerda',
);

const _moverParaDireita = CustomSemanticsAction(label: 'Mover para a direita');

/// Produto no editor da página: alça de arrastar (dentro de um
/// `ReorderableListView` horizontal), foto pequena, nome e preço.
class AppEditorProduto extends StatelessWidget {
  const AppEditorProduto({
    super.key,
    required this.produto,
    required this.indice,
    this.habilitado = true,
    this.aoEsquerda,
    this.aoDireita,
  });

  final ProdutoEstruturaResponse produto;

  final int indice;

  final bool habilitado;

  final VoidCallback? aoEsquerda;

  final VoidCallback? aoDireita;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final urlFoto = produto.urlFoto;
    final semFoto = Icon(
      Icons.sell_outlined,
      size: AppIcones.padrao,
      color: cores.onSurfaceVariant,
    );
    final aoEsquerda = this.aoEsquerda;
    final aoDireita = this.aoDireita;
    return Semantics(
      container: true,
      label: produto.nome,
      customSemanticsActions: habilitado
          ? {_moverParaEsquerda: ?aoEsquerda, _moverParaDireita: ?aoDireita}
          : null,
      child: SizedBox(
        width: AppLayout.larguraCartaoProdutoEditor,
        child: Card(
          margin: const EdgeInsets.only(right: AppEspacamentos.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppEspacamentos.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRaios.bordaSm,
                      child: SizedBox.square(
                        dimension: AppIcones.destaque,
                        child: urlFoto == null
                            ? semFoto
                            : Image.network(
                                urlFoto,
                                fit: BoxFit.cover,
                                excludeFromSemantics: true,
                                errorBuilder: (_, _, _) => semFoto,
                              ),
                      ),
                    ),
                    const Spacer(),
                    if (habilitado)
                      ReorderableDragStartListener(
                        index: indice,
                        child: SizedBox.square(
                          dimension: AppLayout.alvoMinimo,
                          child: Icon(
                            Icons.drag_indicator,
                            color: cores.onSurfaceVariant,
                            semanticLabel: 'Arrastar ${produto.nome}',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppEspacamentos.sm),
                Text(
                  produto.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  Centavos.formatar(produto.precoPromocionalCentavos),
                  style: tema.textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
