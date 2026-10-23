import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Seção Início no celular: um cartão por número, em coluna.
class ResumoInicio extends StatelessWidget {
  const ResumoInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    return switch (controller.resumo) {
      ResumoCarregando() => const EsqueletoLista(),
      ResumoComFalha(:final falha) => EstadoFalha(
        mensagem: falha.mensagem,
        aoTentarDeNovo: controller.carregarResumo,
      ),
      ResumoCarregado(:final resumo) => ListView(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        children: [
          _Numero(
            icone: SecaoPainel.filiais.iconeSelecionado,
            rotulo: 'Filiais',
            valor: resumo.filiais,
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
