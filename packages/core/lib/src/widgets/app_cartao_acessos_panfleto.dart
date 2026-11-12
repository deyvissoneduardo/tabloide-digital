import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/responses/acessos_panfletos_response.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/utils/formatar_numero.dart';

class AppCartaoAcessosPanfleto extends StatelessWidget {
  const AppCartaoAcessosPanfleto({
    super.key,
    required this.item,
    required this.melhorMedia,
  });

  final AcessosPanfletoResponse item;

  final bool melhorMedia;

  String get _periodo => switch (item) {
    AcessosPanfletoResponse(
      situacao: SituacaoAcessoPanfleto.vigente,
      dataLimite: null,
      :final dataInicio,
    ) =>
      'Desde ${DataDia.curta(dataInicio)}',
    AcessosPanfletoResponse(
      situacao: SituacaoAcessoPanfleto.vigente,
      :final dataInicio,
      :final dataLimite?,
    ) =>
      '${DataDia.curta(dataInicio)} a ${DataDia.curta(dataLimite)}',
    AcessosPanfletoResponse(:final dataInicio, :final dataFimContagem) =>
      '${DataDia.curta(dataInicio)} a ${DataDia.curta(dataFimContagem)}',
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final porDia = formatarDecimal(item.mediaPorDia);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        child: Row(
          spacing: AppEspacamentos.sm,
          children: [
            Icon(Icons.campaign_outlined, color: tema.colorScheme.primary),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_periodo, style: tema.textTheme.titleSmall),
                  Text(item.situacao.rotulo, style: suave),
                  const SizedBox(height: AppEspacamentos.xs),
                  Text(
                    '${formatarInteiro(item.totalAcessos)} acessos · '
                    '$porDia por dia',
                    style: tema.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (melhorMedia)
              Chip(
                avatar: Icon(
                  Icons.emoji_events_outlined,
                  color: tema.colorScheme.onSecondaryContainer,
                ),
                backgroundColor: tema.colorScheme.secondaryContainer,
                label: Text(
                  'Melhor média',
                  style: tema.textTheme.labelSmall?.copyWith(
                    color: tema.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
