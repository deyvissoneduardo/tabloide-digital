import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/resumo_acessos_response.dart';
import 'package:tabloide_core/src/theme/app_cores.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';
import 'package:tabloide_core/src/utils/formatar_numero.dart';

class AppRankingFiliais extends StatelessWidget {
  const AppRankingFiliais({super.key, required this.filiais});

  final List<AcessosFilialResponse> filiais;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final maior = filiais.fold(0, (m, f) => f.total > m ? f.total : m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppEspacamentos.md,
      children: [
        for (final filial in filiais)
          Semantics(
            label:
                '${filial.nome}${filial.excluida ? ', filial excluída' : ''}: '
                '${formatarInteiro(filial.total)} acessos',
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppEspacamentos.xs,
                children: [
                  Row(
                    spacing: AppEspacamentos.sm,
                    children: [
                      Expanded(
                        child: Text(
                          filial.nome,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodyMedium,
                        ),
                      ),
                      if (filial.excluida)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          side: const BorderSide(color: AppCores.alerta),
                          label: Text(
                            'Filial excluída',
                            style: tema.textTheme.labelSmall?.copyWith(
                              color: AppCores.alerta,
                            ),
                          ),
                        ),
                      Text(
                        formatarInteiro(filial.total),
                        style: tema.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: AppRaios.bordaPilula,
                    child: LinearProgressIndicator(
                      value: maior == 0 ? 0 : filial.total / maior,
                      color: filial.excluida
                          ? tema.colorScheme.outline
                          : tema.colorScheme.primary,
                      backgroundColor: tema.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
