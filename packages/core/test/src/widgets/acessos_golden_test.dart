import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

class _ComponentesAcessos extends StatelessWidget {
  const _ComponentesAcessos();

  @override
  Widget build(BuildContext context) {
    final pico = resumoAcessosFake.pico;
    return ListView(
      padding: const EdgeInsets.all(AppEspacamentos.md),
      children: [
        AppFiltroPeriodo(
          valor: PeriodoAcessos.padrao,
          aoMudar: (_) {},
          hoje: DateTime(2026, 11, 9),
        ),
        const SizedBox(height: AppEspacamentos.sm),
        AppFiltroPeriodo(
          valor: PeriodoPersonalizado(
            DateTime(2026, 10, 1),
            DateTime(2026, 10, 31),
          ),
          aoMudar: (_) {},
          hoje: DateTime(2026, 11, 9),
        ),
        const SizedBox(height: AppEspacamentos.md),
        const AppIndicadorNumero(
          rotulo: 'Acessos',
          valor: 1925,
          apoio: 'Últimos 30 dias',
        ),
        const SizedBox(height: AppEspacamentos.md),
        AppGraficoAcessosDia(
          dias: resumoAcessosFake.porDia,
          marcadores: [
            for (final inicio in resumoAcessosFake.iniciosPanfleto) inicio.data,
          ],
        ),
        const SizedBox(height: AppEspacamentos.md),
        AppGraficoAcessosDia(
          dias: [AcessosDiaResponse(data: DateTime(2026, 11, 9), total: 37)],
          marcadores: const [],
        ),
        const SizedBox(height: AppEspacamentos.md),
        AppGraficoBarras(
          valores: pico.porHora!,
          rotulos: [for (var h = 0; h < 24; h++) '${h}h'],
          descricao: 'Por horário',
          passoRotulos: 6,
        ),
        const SizedBox(height: AppEspacamentos.md),
        AppGraficoBarras(
          valores: pico.porDiaSemana!,
          rotulos: const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
          descricao: 'Por dia da semana',
        ),
        const SizedBox(height: AppEspacamentos.md),
        AppRankingFiliais(filiais: resumoAcessosFake.porFilial),
        const SizedBox(height: AppEspacamentos.md),
        for (final (i, item) in panfletosAcessosFake.itens.indexed)
          AppCartaoAcessosPanfleto(item: item, melhorMedia: i == 0),
      ],
    );
  }
}

void main() {
  goldenTest(
    'Cenário: Dado os componentes de acessos, então filtro, número, gráficos, ranking e cartões de panfleto seguem o tema',
    fileName: 'acessos_componentes',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Filtros, número, gráficos, ranking e panfletos',
          constraints: const BoxConstraints.tightFor(width: 360, height: 1500),
          child: montarComMarca(
            const SizedBox.expand(child: _ComponentesAcessos()),
          ),
        ),
      ],
    ),
  );
}
