import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/responses/resumo_acessos_response.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/utils/formatar_numero.dart';

class AppGraficoAcessosDia extends StatelessWidget {
  const AppGraficoAcessosDia({
    super.key,
    required this.dias,
    required this.marcadores,
  });

  static const _maximoRotulos = 6;

  final List<AcessosDiaResponse> dias;

  final List<DateTime> marcadores;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final rotulo = tema.textTheme.labelSmall?.copyWith(
      color: cores.onSurfaceVariant,
    );
    if (dias.isEmpty) return const SizedBox.shrink();
    var maior = dias.first;
    var total = 0;
    for (final dia in dias) {
      total += dia.total;
      if (dia.total > maior.total) maior = dia;
    }
    final descricao =
        'Acessos por dia, total ${formatarInteiro(total)}, maior dia '
        '${DataDia.curta(maior.data)} com ${formatarInteiro(maior.total)}';
    if (dias.length == 1) {
      return Semantics(
        label: descricao,
        child: ExcludeSemantics(
          child: SizedBox(
            height: AppLayout.alturaGraficoBarras,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatarInteiro(maior.total),
                    style: tema.textTheme.displaySmall?.copyWith(
                      color: cores.primary,
                    ),
                  ),
                  Text(
                    'acessos em ${DataDia.curta(maior.data)}',
                    style: rotulo,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final indiceDe = {
      for (final (i, dia) in dias.indexed) DataDia.iso(dia.data): i,
    };
    final indicesMarcados = {
      for (final marcador in marcadores) ?indiceDe[DataDia.iso(marcador)],
    };
    final passo = ((dias.length - 1) / (_maximoRotulos - 1)).ceil();
    return Semantics(
      label: descricao,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: AppLayout.alturaGrafico,
              child: LineChart(
                duration: Duration.zero,
                LineChartData(
                  minY: 0,
                  minX: 0,
                  maxX: (dias.length - 1).toDouble(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: cores.outlineVariant, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: AppEspacamentos.xl + AppEspacamentos.sm,
                        getTitlesWidget: (valor, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            valor == meta.max && valor != meta.min
                                ? ''
                                : formatarInteiro(valor.round()),
                            style: rotulo,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: AppEspacamentos.lg,
                        getTitlesWidget: (valor, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            valor.round() % passo == 0
                                ? DataDia.curta(dias[valor.round()].data)
                                : '',
                            style: rotulo,
                          ),
                        ),
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    verticalLines: [
                      for (final indice in indicesMarcados)
                        VerticalLine(
                          x: indice.toDouble(),
                          color: cores.secondary,
                          strokeWidth: 2,
                          dashArray: const [4, 4],
                        ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => cores.inverseSurface,
                      getTooltipItems: (pontos) => [
                        for (final ponto in pontos)
                          LineTooltipItem(
                            '${DataDia.curta(dias[ponto.x.round()].data)}: '
                            '${formatarInteiro(ponto.y.round())} acessos',
                            tema.textTheme.labelMedium!.copyWith(
                              color: cores.onInverseSurface,
                            ),
                          ),
                      ],
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (final (i, dia) in dias.indexed)
                          FlSpot(i.toDouble(), dia.total.toDouble()),
                      ],
                      color: cores.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: cores.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (indicesMarcados.isNotEmpty) ...[
              const SizedBox(height: AppEspacamentos.sm),
              Row(
                spacing: AppEspacamentos.xs,
                children: [
                  Icon(Icons.more_vert, color: cores.secondary),
                  Text('Novo panfleto', style: rotulo),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
