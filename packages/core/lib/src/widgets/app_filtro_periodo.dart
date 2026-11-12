import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/acessos/models/periodo_acessos.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/widgets/app_aviso.dart';
import 'package:tabloide_core/src/widgets/feedback.dart';

class AppFiltroPeriodo extends StatelessWidget {
  const AppFiltroPeriodo({
    super.key,
    required this.valor,
    required this.aoMudar,
    required this.hoje,
  });

  final PeriodoAcessos valor;

  final ValueChanged<PeriodoAcessos> aoMudar;

  final DateTime hoje;

  static String rotuloDe(int dias) => dias == 1 ? 'Hoje' : '$dias dias';

  Future<void> _escolherPersonalizado(BuildContext context) async {
    final escolhido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(hoje.year - 5, hoje.month, hoje.day),
      lastDate: hoje,
      initialDateRange: switch (valor) {
        PeriodoPersonalizado(:final inicio, :final fim) => DateTimeRange(
          start: inicio,
          end: fim,
        ),
        PeriodoPredefinido() => null,
      },
      helpText: 'Escolha o período',
      cancelText: 'Cancelar',
      saveText: 'Aplicar',
      confirmText: 'Aplicar',
    );
    if (escolhido == null || !context.mounted) return;
    final periodo = PeriodoPersonalizado(
      DataDia.de(escolhido.start),
      DataDia.de(escolhido.end),
    );
    if (periodo.dias > PeriodoAcessos.maximoDias) {
      mostrarAviso(
        context,
        'Escolha no máximo ${PeriodoAcessos.maximoDias} dias.',
        tipo: TipoAviso.alerta,
      );
      return;
    }
    if (periodo != valor) aoMudar(periodo);
  }

  @override
  Widget build(BuildContext context) {
    final periodo = valor;
    return Wrap(
      spacing: AppEspacamentos.sm,
      runSpacing: AppEspacamentos.sm,
      children: [
        for (final dias in PeriodoAcessos.diasPredefinidos)
          ChoiceChip(
            label: Text(rotuloDe(dias)),
            selected: periodo == PeriodoPredefinido(dias),
            onSelected: (_) {
              final novo = PeriodoPredefinido(dias);
              if (novo != periodo) aoMudar(novo);
            },
          ),
        ChoiceChip(
          avatar: const Icon(Icons.date_range_outlined),
          showCheckmark: false,
          label: Text(switch (periodo) {
            PeriodoPersonalizado(:final inicio, :final fim) =>
              '${DataDia.curta(inicio)} – ${DataDia.curta(fim)}',
            PeriodoPredefinido() => 'Personalizado',
          }),
          selected: periodo is PeriodoPersonalizado,
          onSelected: (_) => _escolherPersonalizado(context),
        ),
      ],
    );
  }
}
