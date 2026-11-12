import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';
import 'package:tabloide_core/src/utils/formatar_numero.dart';

class AppGraficoBarras extends StatelessWidget {
  const AppGraficoBarras({
    super.key,
    required this.valores,
    required this.rotulos,
    required this.descricao,
    this.passoRotulos = 1,
  });

  final List<int> valores;

  final List<String> rotulos;

  final String descricao;

  final int passoRotulos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    var indiceMaior = 0;
    for (final (i, valor) in valores.indexed) {
      if (valor > valores[indiceMaior]) indiceMaior = i;
    }
    final maior = valores.isEmpty ? 0 : valores[indiceMaior];
    final semDados = maior == 0;
    return Semantics(
      label: semDados
          ? '$descricao: sem acessos'
          : '$descricao: maior movimento em ${rotulos[indiceMaior]}, '
                'com ${formatarInteiro(maior)} acessos',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: AppLayout.alturaGraficoBarras,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: AppEspacamentos.xs / 2,
                children: [
                  for (final (i, valor) in valores.indexed)
                    Expanded(
                      child: Container(
                        height: semDados
                            ? 0
                            : AppLayout.alturaGraficoBarras * valor / maior,
                        decoration: BoxDecoration(
                          color: !semDados && i == indiceMaior
                              ? cores.secondary
                              : cores.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRaios.sm / 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppEspacamentos.xs),
            Row(
              spacing: AppEspacamentos.xs / 2,
              children: [
                for (final (i, rotulo) in rotulos.indexed)
                  Expanded(
                    child: Text(
                      i % passoRotulos == 0 ? rotulo : '',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
