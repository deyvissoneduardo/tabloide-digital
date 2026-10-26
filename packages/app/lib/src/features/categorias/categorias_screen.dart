import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/categorias/categoria_form_screen.dart';
import 'package:tabloide_app/src/features/categorias/categorias_controller.dart';
import 'package:tabloide_app/src/features/categorias/categorias_estado.dart';
import 'package:tabloide_core/tabloide_core.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key, required this.filialId});

  final String filialId;

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() =>
      context.read<CategoriasController>().carregar(widget.filialId);

  Future<void> _abrirFormulario({CategoriaResponse? categoria}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CategoriaFormScreen(
            filialId: widget.filialId,
            categoria: categoria,
          ),
        ),
      );

  Future<void> _agir(CategoriaResponse categoria, AcaoCategoria acao) async {
    switch (acao) {
      case AcaoCategoria.renomear:
        await _abrirFormulario(categoria: categoria);
      case AcaoCategoria.excluir:
        await _excluir(categoria);
    }
  }

  Future<void> _excluir(CategoriaResponse categoria) async {
    final controller = context.read<CategoriasController>();
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir a categoria ${categoria.nome}?',
      mensagem: categoria.produtos.vencidos > 0
          ? 'Os produtos vencidos desta categoria também serão excluídos.'
          : 'Ela deixa de aparecer na lista de categorias.',
      rotuloConfirmar: 'Excluir categoria',
    );
    if (!confirmou || !mounted) return;
    final resultado = await controller.excluir(categoria);
    if (!mounted) return;
    switch (resultado) {
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case Success():
        mostrarAviso(context, 'Categoria excluída.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CategoriasController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: switch (controller.estado) {
        _ when controller.filialId != widget.filialId => const EsqueletoLista(),
        CategoriasCarregando() => const EsqueletoLista(),
        CategoriasComFalha(:final falha) => EstadoFalha(
          mensagem: falha.mensagem,
          aoTentarDeNovo: _carregar,
        ),
        CategoriasCarregadas(:final categorias) when categorias.isEmpty =>
          EstadoVazio(
            icone: Icons.category_outlined,
            titulo: 'Nenhuma categoria ainda',
            mensagem: 'Todo produto fica em uma categoria. Crie a primeira, como "Mercearia" ou "Bebidas".',
            rotuloAcao: 'Nova categoria',
            aoAgir: _abrirFormulario,
          ),
        CategoriasCarregadas(:final categorias) => ListView(
          padding: const EdgeInsets.all(AppEspacamentos.md),
          children: [
            AppBotaoPrincipal(
              rotulo: 'Nova categoria',
              aoPressionar: _abrirFormulario,
            ),
            const SizedBox(height: AppEspacamentos.md),
            for (final categoria in categorias)
              AppCartaoCategoria(
                categoria: categoria,
                aoTocar: () => _abrirFormulario(categoria: categoria),
                aoEscolherAcao: (acao) => _agir(categoria, acao),
              ),
          ],
        ),
      },
    );
  }
}
