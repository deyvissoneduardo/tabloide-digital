import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/acessos/acessos_controller.dart';
import 'package:tabloide_web/src/features/acessos/acessos_estado.dart';
import 'package:tabloide_web/src/features/acessos/widgets/bloco_acessos_panfletos.dart';
import 'package:tabloide_web/src/features/acessos/widgets/bloco_pico.dart';
import 'package:tabloide_web/src/features/acessos/widgets/filtros_acessos.dart';

class SecaoAcessos extends StatelessWidget {
  const SecaoAcessos({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controller = context.watch<AcessosController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppEspacamentos.lg,
            bottom: AppEspacamentos.xs,
          ),
          child: Text(
            'Acessos à sua página',
            style: tema.textTheme.titleMedium,
          ),
        ),
        Text(
          'Cada abertura da página conta um acesso. Recarregar logo em '
          'seguida não conta de novo.',
          style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppEspacamentos.md),
        const FiltrosAcessos(),
        SizedBox(
          height: AppEspacamentos.md,
          child: controller.recarregando
              ? const Center(child: LinearProgressIndicator())
              : null,
        ),
        switch (controller.resumo) {
          ResumoAcessosCarregando() => const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppEspacamentos.sm,
            children: [
              Esqueleto(altura: 96),
              Esqueleto(altura: AppLayout.alturaGrafico),
              Esqueleto(altura: AppLayout.alturaGraficoBarras),
            ],
          ),
          ResumoAcessosComFalha(:final falha) => EstadoFalha(
            mensagem: falha.mensagem,
            aoTentarDeNovo: controller.carregar,
          ),
          ResumoAcessosCarregado(:final resumo) when resumo.total == 0 =>
            const EstadoVazio(
              icone: Icons.qr_code_2,
              titulo: 'Ainda não há acessos neste período',
              mensagem:
                  'Assim que alguém abrir sua página, os acessos aparecem '
                  'aqui.',
            ),
          ResumoAcessosCarregado(:final resumo, :final periodo) =>
            _ConteudoAcessos(resumo: resumo, periodo: periodo),
        },
      ],
    );
  }
}

class _ConteudoAcessos extends StatelessWidget {
  const _ConteudoAcessos({required this.resumo, required this.periodo});

  final ResumoAcessosResponse resumo;

  final PeriodoAcessos periodo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final comRanking = resumo.porFilial.length >= 2;
    final pico = _Cartao(child: BlocoPico(pico: resumo.pico));
    final ranking = _Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppEspacamentos.md,
        children: [
          Text('Acessos por filial', style: tema.textTheme.titleSmall),
          AppRankingFiliais(filiais: resumo.porFilial),
        ],
      ),
    );
    final duasColunas =
        comRanking && ClasseTamanho.de(context) == ClasseTamanho.expandido;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppEspacamentos.sm,
      children: [
        AppIndicadorNumero(
          rotulo: 'Acessos',
          valor: resumo.total,
          apoio: switch (periodo) {
            PeriodoPredefinido(dias: 1) => 'Hoje',
            PeriodoPredefinido(:final dias) => 'Últimos $dias dias',
            PeriodoPersonalizado(:final inicio, :final fim) =>
              '${DataDia.curta(inicio)} a ${DataDia.curta(fim)}',
          },
        ),
        _Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppEspacamentos.md,
            children: [
              Text('Acessos por dia', style: tema.textTheme.titleSmall),
              AppGraficoAcessosDia(
                dias: resumo.porDia,
                marcadores: [
                  for (final inicio in resumo.iniciosPanfleto) inicio.data,
                ],
              ),
            ],
          ),
        ),
        if (duasColunas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppEspacamentos.sm,
            children: [
              Expanded(child: pico),
              Expanded(child: ranking),
            ],
          )
        else ...[
          pico,
          if (comRanking) ranking,
        ],
        const _Cartao(child: BlocoAcessosPanfletos()),
      ],
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppEspacamentos.md),
      child: child,
    ),
  );
}
