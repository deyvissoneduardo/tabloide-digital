import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/src/features/categorias/categorias_controller.dart';
import 'package:tabloide_web/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_web/src/features/produtos/produto_form_screen.dart';
import 'package:tabloide_web/src/features/produtos/services/produto_service_web.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Lista vertical de categorias, cada uma com os produtos na horizontal.
/// Tocar num produto abre o formulário de produto; salvar grava só o produto
/// (U17).
class EditorPagina extends StatefulWidget {
  const EditorPagina({super.key, required this.exibePanfleto});

  final bool exibePanfleto;

  @override
  State<EditorPagina> createState() => _EditorPaginaState();
}

class _EditorPaginaState extends State<EditorPagina> {
  String? _abrindo;

  Future<void> _editar(ProdutoEstruturaResponse item) async {
    final pagina = context.read<PaginaController>();
    final filialId = pagina.filialId;
    if (filialId == null || _abrindo != null) return;
    setState(() => _abrindo = item.id);
    final (produto, _) = await (
      context.read<ProdutoServiceWeb>().obter(filialId, item.id),
      context.read<CategoriasController>().carregar(filialId),
    ).wait;
    if (!mounted) return;
    setState(() => _abrindo = null);
    switch (produto) {
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case Success(valor: final produto):
        final editado = await Navigator.of(context).push<ProdutoResponse>(
          MaterialPageRoute(
            builder: (_) =>
                ProdutoFormScreen(filialId: filialId, produto: produto),
          ),
        );
        if (editado != null && filialId == pagina.filialId) {
          pagina.produtoEditado(editado);
        }
    }
  }

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
      header: widget.exibePanfleto
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
          aoTocarProduto: _editar,
          produtoCarregando: _abrindo,
        );
      },
    );
  }
}
