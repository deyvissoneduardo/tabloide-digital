import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/filiais/filiais_estado.dart';
import 'package:tabloide_app/src/features/home/widgets/secao_paginas_publicadas.dart';
import 'package:tabloide_core/tabloide_core.dart';

class ResumoInicio extends StatefulWidget {
  const ResumoInicio({super.key});

  @override
  State<ResumoInicio> createState() => _ResumoInicioState();
}

class _ResumoInicioState extends State<ResumoInicio> {
  List<String>? _pedido;

  Future<void> _carregar(List<String> ids) =>
      context.read<HomeController>().carregarResumo(ids);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final filiais = context.watch<FiliaisController>();
    if (filiais.estado is FiliaisCarregando) return const EsqueletoLista();
    final ids = [for (final filial in filiais.filiais) filial.id];
    if (!listEquals(_pedido, ids)) {
      _pedido = ids;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _carregar(ids);
      });
    }
    return switch (controller.resumo) {
      _ when !listEquals(controller.filialIds, ids) => const EsqueletoLista(),
      ResumoCarregando() => const EsqueletoLista(),
      ResumoComFalha(:final falha) => EstadoFalha(
        mensagem: falha.mensagem,
        aoTentarDeNovo: () => _carregar(ids),
      ),
      ResumoCarregado(:final resumo) => ListView(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        children: [
          _Numero(
            icone: SecaoPainel.filiais.iconeSelecionado,
            rotulo: 'Filiais',
            valor: ids.length,
          ),
          _Numero(
            icone: SecaoPainel.panfletos.iconeSelecionado,
            rotulo: 'Panfletos no ar',
            valor: resumo.panfletosVigentes,
          ),
          _Numero(
            icone: SecaoPainel.produtos.iconeSelecionado,
            rotulo: 'Produtos no ar',
            valor: resumo.produtosVigentes,
          ),
          SecaoPaginasPublicadas(resumo: resumo),
        ],
      ),
    };
  }
}

class _Numero extends StatelessWidget {
  const _Numero({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final int valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icone, color: tema.colorScheme.primary),
        title: Text(rotulo),
        trailing: Text('$valor', style: tema.textTheme.headlineSmall),
      ),
    );
  }
}
