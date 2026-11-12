import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

const _diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

const _diasSemanaPorExtenso = [
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
  'domingo',
];

int _indiceDoMaior(List<int> valores) {
  var indice = 0;
  for (final (i, valor) in valores.indexed) {
    if (valor > valores[indice]) indice = i;
  }
  return indice;
}

class BlocoPico extends StatelessWidget {
  const BlocoPico({super.key, required this.pico});

  final PicoAcessosResponse pico;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final suave = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final titulo = Text('Horários de pico', style: tema.textTheme.titleSmall);
    if (pico case PicoAcessosResponse(
      disponivel: true,
      :final porHora?,
      :final porDiaSemana?,
    )) {
      final hora = _indiceDoMaior(porHora);
      final dia = _diasSemanaPorExtenso[_indiceDoMaior(porDiaSemana)];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppEspacamentos.sm,
        children: [
          titulo,
          Text(
            'Mais movimento: $dia, entre ${hora}h e ${(hora + 1) % 24}h.',
            style: suave,
          ),
          const SizedBox(height: AppEspacamentos.xs),
          Text('Por horário', style: tema.textTheme.labelLarge),
          AppGraficoBarras(
            valores: porHora,
            rotulos: [for (var h = 0; h < 24; h++) '${h}h'],
            descricao: 'Acessos por horário',
            passoRotulos: 6,
          ),
          const SizedBox(height: AppEspacamentos.xs),
          Text('Por dia da semana', style: tema.textTheme.labelLarge),
          AppGraficoBarras(
            valores: porDiaSemana,
            rotulos: _diasSemana,
            descricao: 'Acessos por dia da semana',
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppEspacamentos.sm,
      children: [
        titulo,
        Text(
          'Ainda não há acessos suficientes para mostrar os horários de pico '
          '(mínimo de ${pico.minimo} no período).',
          style: suave,
        ),
      ],
    );
  }
}
