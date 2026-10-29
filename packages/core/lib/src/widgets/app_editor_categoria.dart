import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/widgets/app_editor_produto.dart';

const _moverParaCima = CustomSemanticsAction(label: 'Mover para cima');

const _moverParaBaixo = CustomSemanticsAction(label: 'Mover para baixo');

/// Categoria no editor da página: alça para arrastar na lista vertical (fica
/// dentro de um `ReorderableListView`) e produtos numa faixa horizontal
/// reordenável. Ações semânticas permitem reordenar sem arrastar (RNF10).
class AppEditorCategoria extends StatelessWidget {
  const AppEditorCategoria({
    super.key,
    required this.categoria,
    required this.indice,
    required this.aoMoverProduto,
    this.habilitado = true,
    this.aoSubir,
    this.aoDescer,
    this.aoProdutoEsquerda,
    this.aoProdutoDireita,
    this.aoTocarProduto,
    this.produtoCarregando,
  });

  final CategoriaEstruturaResponse categoria;

  final int indice;

  final bool habilitado;

  /// Índices como o `onReorderItem` do `ReorderableListView` entrega
  /// (`para` já é a posição final).
  final void Function(int de, int para) aoMoverProduto;

  final VoidCallback? aoSubir;

  final VoidCallback? aoDescer;

  final ValueChanged<int>? aoProdutoEsquerda;

  final ValueChanged<int>? aoProdutoDireita;

  /// Toque num produto (abre o formulário, U17).
  final ValueChanged<ProdutoEstruturaResponse>? aoTocarProduto;

  /// Id do produto que está sendo aberto (spinner no cartão).
  final String? produtoCarregando;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final produtos = categoria.produtos;
    final aoSubir = this.aoSubir;
    final aoDescer = this.aoDescer;
    final aoProdutoEsquerda = this.aoProdutoEsquerda;
    final aoProdutoDireita = this.aoProdutoDireita;
    final aoTocarProduto = this.aoTocarProduto;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacamentos.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              container: true,
              label: categoria.nome,
              customSemanticsActions: habilitado
                  ? {_moverParaCima: ?aoSubir, _moverParaBaixo: ?aoDescer}
                  : null,
              child: Row(
                children: [
                  if (habilitado)
                    ReorderableDragStartListener(
                      index: indice,
                      child: SizedBox.square(
                        dimension: AppLayout.alvoMinimo,
                        child: Icon(
                          Icons.drag_indicator,
                          color: cores.onSurfaceVariant,
                          semanticLabel: 'Arrastar ${categoria.nome}',
                        ),
                      ),
                    ),
                  const SizedBox(width: AppEspacamentos.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(categoria.nome, style: tema.textTheme.titleMedium),
                        Text(
                          produtos.length == 1
                              ? '1 produto'
                              : '${produtos.length} produtos',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: cores.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppEspacamentos.sm),
            if (produtos.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppEspacamentos.sm),
                child: Text(
                  'Sem produtos vigentes ou agendados',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: cores.onSurfaceVariant,
                  ),
                ),
              )
            else
              SizedBox(
                height: AppLayout.alturaCarrosselEditor,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: produtos.length,
                  onReorderItem: habilitado ? aoMoverProduto : (_, _) {},
                  itemBuilder: (_, i) => AppEditorProduto(
                    key: ValueKey(produtos[i].id),
                    produto: produtos[i],
                    indice: i,
                    habilitado: habilitado,
                    carregando: produtos[i].id == produtoCarregando,
                    aoTocar: aoTocarProduto == null
                        ? null
                        : () => aoTocarProduto(produtos[i]),
                    aoEsquerda: i > 0 && aoProdutoEsquerda != null
                        ? () => aoProdutoEsquerda(i)
                        : null,
                    aoDireita:
                        i < produtos.length - 1 && aoProdutoDireita != null
                        ? () => aoProdutoDireita(i)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
