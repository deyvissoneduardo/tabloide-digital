import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/categorias/categoria_form_screen.dart';
import 'package:tabloide_app/src/features/categorias/categorias_controller.dart';
import 'package:tabloide_app/src/features/categorias/categorias_estado.dart';
import 'package:tabloide_app/src/features/categorias/categorias_screen.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/produtos/produto_form_screen.dart';
import 'package:tabloide_app/src/features/produtos/produtos_controller.dart';
import 'package:tabloide_app/src/features/produtos/produtos_estado.dart';
import 'package:tabloide_core/tabloide_core.dart';

class SecaoProdutos extends StatefulWidget {
  const SecaoProdutos({super.key});

  @override
  State<SecaoProdutos> createState() => _SecaoProdutosState();
}

class _SecaoProdutosState extends State<SecaoProdutos> {
  String? _filialPedida;

  @override
  void initState() {
    super.initState();
    _filialPedida = context.read<FiliaisController>().emUso?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final filial = context.read<FiliaisController>().emUso;
    if (filial == null) return;
    _filialPedida = filial.id;
    await Future.wait([
      context.read<ProdutosController>().carregar(filial.id),
      context.read<CategoriasController>().carregar(filial.id),
    ]);
  }

  Future<void> _abrir(Widget tela) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => tela));

  Future<void> _abrirCategorias(FilialResponse filial) async {
    await _abrir(CategoriasScreen(filialId: filial.id));
    if (!mounted) return;
    await context.read<ProdutosController>().carregar(filial.id);
  }

  Future<void> _agir(
    FilialResponse filial,
    ProdutoResponse produto,
    AcaoProduto acao,
  ) async {
    switch (acao) {
      case AcaoProduto.editar:
        await _abrir(ProdutoFormScreen(filialId: filial.id, produto: produto));
      case AcaoProduto.excluir:
        await _excluir(produto);
    }
  }

  Future<void> _excluir(ProdutoResponse produto) async {
    final controller = context.read<ProdutosController>();
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir ${produto.nome}?',
      mensagem: 'Ele sai da página da filial na hora. Para publicar de novo, cadastre um novo produto.',
      rotuloConfirmar: 'Excluir produto',
    );
    if (!confirmou || !mounted) return;
    final resultado = await controller.excluir(produto);
    if (!mounted) return;
    switch (resultado) {
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case Success():
        mostrarAviso(context, 'Produto excluído.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filial = context.watch<FiliaisController>().emUso;
    final produtos = context.watch<ProdutosController>();
    final categorias = context.watch<CategoriasController>();
    final tema = Theme.of(context);
    if (filial == null) {
      return const EstadoVazio(
        icone: Icons.storefront_outlined,
        titulo: 'Escolha uma filial',
        mensagem: 'Cada filial tem os próprios produtos. Escolha a filial em uso na aba Filiais.',
      );
    }
    if (produtos.filialId != filial.id || categorias.filialId != filial.id) {
      if (_filialPedida != filial.id) {
        _filialPedida = filial.id;
        WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
      }
      return const EsqueletoLista();
    }
    final botaoCategorias = OutlinedButton.icon(
      onPressed: () => _abrirCategorias(filial),
      icon: const Icon(Icons.category_outlined),
      label: const Text('Categorias'),
    );
    return switch ((produtos.estado, categorias.estado)) {
      (ProdutosCarregando(), _) ||
      (_, CategoriasCarregando()) => const EsqueletoLista(),
      (ProdutosComFalha(:final falha), _) ||
      (
        _,
        CategoriasComFalha(:final falha),
      ) => EstadoFalha(mensagem: falha.mensagem, aoTentarDeNovo: _carregar),
      (
        ProdutosCarregados(:final produtos),
        CategoriasCarregadas(:final categorias),
      )
          when produtos.isEmpty && categorias.isEmpty =>
        EstadoVazio(
          icone: Icons.category_outlined,
          titulo: 'Crie a primeira categoria',
          mensagem: 'Todo produto fica em uma categoria, como "Mercearia" ou "Bebidas".',
          rotuloAcao: 'Nova categoria',
          aoAgir: () => _abrir(CategoriaFormScreen(filialId: filial.id)),
        ),
      (ProdutosCarregados(:final produtos), CategoriasCarregadas())
          when produtos.isEmpty =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppEspacamentos.md),
              child: botaoCategorias,
            ),
            Expanded(
              child: EstadoVazio(
                icone: SecaoPainel.produtos.iconeSelecionado,
                titulo: 'Nenhum produto na filial ${filial.nome}',
                mensagem: 'Cadastre as ofertas para elas aparecerem na página da filial.',
                rotuloAcao: 'Novo produto',
                aoAgir: () => _abrir(ProdutoFormScreen(filialId: filial.id)),
              ),
            ),
          ],
        ),
      (ProdutosCarregados(), CategoriasCarregadas()) => ListView(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        children: [
          AppBotaoPrincipal(
            rotulo: 'Novo produto',
            aoPressionar: () => _abrir(ProdutoFormScreen(filialId: filial.id)),
          ),
          const SizedBox(height: AppEspacamentos.sm),
          botaoCategorias,
          for (final (:categoria, produtos: daCategoria)
              in produtos.grupos) ...[
            const SizedBox(height: AppEspacamentos.lg),
            Text(categoria.nome, style: tema.textTheme.titleMedium),
            const SizedBox(height: AppEspacamentos.sm),
            for (final produto in daCategoria)
              AppCartaoProduto(
                produto: produto,
                aoTocar: produto.vigencia.editavel
                    ? () => _abrir(
                        ProdutoFormScreen(
                          filialId: filial.id,
                          produto: produto,
                        ),
                      )
                    : null,
                aoEscolherAcao: (acao) => _agir(filial, produto, acao),
              ),
          ],
        ],
      ),
    };
  }
}
