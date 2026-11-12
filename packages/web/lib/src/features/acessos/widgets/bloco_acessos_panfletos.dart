import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/acessos/acessos_controller.dart';
import 'package:tabloide_web/src/features/acessos/acessos_estado.dart';

class BlocoAcessosPanfletos extends StatelessWidget {
  const BlocoAcessosPanfletos({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controller = context.watch<AcessosController>();
    final suave = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppEspacamentos.sm,
      children: [
        Text(
          'Acessos durante o período do panfleto',
          style: tema.textTheme.titleSmall,
        ),
        switch (controller.panfletos) {
          PanfletosAcessosOcioso() => Text(
            'Escolha uma filial no filtro acima para comparar os panfletos.',
            style: suave,
          ),
          PanfletosAcessosCarregando() => const Esqueleto(altura: 72),
          PanfletosAcessosComFalha(:final falha) => EstadoFalha(
            mensagem: falha.mensagem,
            aoTentarDeNovo: controller.carregar,
          ),
          PanfletosAcessosCarregados(:final itens) when itens.isEmpty => Text(
            'Nenhum panfleto nesse período.',
            style: suave,
          ),
          PanfletosAcessosCarregados(:final itens) => _ListaPanfletos(
            itens: itens,
          ),
        },
        Text(
          'Comparação pela média por dia, para panfletos de durações '
          'diferentes.',
          style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ListaPanfletos extends StatelessWidget {
  const _ListaPanfletos({required this.itens});

  final List<AcessosPanfletoResponse> itens;

  @override
  Widget build(BuildContext context) {
    var melhor = 0;
    for (final (i, item) in itens.indexed) {
      if (item.mediaPorDia > itens[melhor].mediaPorDia) melhor = i;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, item) in itens.indexed)
          AppCartaoAcessosPanfleto(
            key: ValueKey(item.panfletoId),
            item: item,
            melhorMedia: itens.length >= 2 && i == melhor,
          ),
      ],
    );
  }
}
