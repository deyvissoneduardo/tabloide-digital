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
      ResumoCarregando() => const Center(child: CircularProgressIndicator()),
      ResumoComFalha(:final falha) => _Falha(
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

class _Falha extends StatelessWidget {
  const _Falha({required this.mensagem, required this.aoTentarDeNovo});

  final String mensagem;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppEspacamentos.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppEspacamentos.md),
          Text(mensagem, textAlign: TextAlign.center),
          const SizedBox(height: AppEspacamentos.md),
          FilledButton(
            onPressed: aoTentarDeNovo,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    ),
  );
}
