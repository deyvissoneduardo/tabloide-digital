import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Lista vertical de categorias, cada uma com os produtos na horizontal.
class EditorPagina extends StatelessWidget {
  const EditorPagina({super.key, required this.exibePanfleto});

  final bool exibePanfleto;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaginaController>();
    final categorias = controller.emEdicao;
    final habilitado = !controller.bloqueado && !controller.publicando;
    if (categorias.isEmpty) {
      return EstadoVazio(
        icone: Icons.category_outlined,
        titulo: 'Crie categorias e produtos para montar a página',
        rotuloAcao: 'Ir para Produtos',
        aoAgir: () =>
            context.read<HomeController>().selecionar(SecaoPainel.produtos),
      );
    }
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(AppEspacamentos.md),
      buildDefaultDragHandles: false,
      header: exibePanfleto
          ? const Card(
              child: Padding(
                padding: EdgeInsets.all(AppEspacamentos.md),
                child: AppAviso(
                  tipo: TipoAviso.info,
                  mensagem: 'A página está mostrando só o panfleto. A ordem vale quando não houver panfleto vigente ou quando a chave estiver desligada no Perfil.',
                ),
              ),
            )
          : null,
      itemCount: categorias.length,
      onReorderItem: controller.moverCategoria,
      itemBuilder: (_, i) {
        final categoria = categorias[i];
        return AppEditorCategoria(
          key: ValueKey(categoria.id),
          categoria: categoria,
          indice: i,
          habilitado: habilitado,
          aoMoverProduto: (de, para) =>
              controller.moverProduto(categoria.id, de, para),
          aoSubir: i > 0 ? () => controller.subir(i) : null,
          aoDescer: i < categorias.length - 1
              ? () => controller.descer(i)
              : null,
          aoProdutoEsquerda: (p) => controller.esquerda(categoria.id, p),
          aoProdutoDireita: (p) => controller.direita(categoria.id, p),
        );
      },
    );
  }
}
