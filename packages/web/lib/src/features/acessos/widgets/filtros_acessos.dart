import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/acessos/acessos_controller.dart';
import 'package:tabloide_web/src/features/filiais/filiais_controller.dart';

const _todas = '';

class FiltrosAcessos extends StatelessWidget {
  const FiltrosAcessos({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AcessosController>();
    final filiais = context.watch<FiliaisController>().filiais;
    final nomes = {for (final filial in filiais) filial.id: filial.nome};
    final escolhida = nomes.containsKey(controller.filialId)
        ? controller.filialId!
        : _todas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppEspacamentos.md,
      children: [
        AppFiltroPeriodo(
          valor: controller.periodo,
          aoMudar: controller.mudarPeriodo,
          hoje: DataDia.hoje(),
        ),
        if (filiais.length >= 2)
          AppCampoSelecao<String>(
            key: ValueKey('filial-acessos-$escolhida'),
            valor: escolhida,
            opcoes: [_todas, ...nomes.keys],
            rotuloDe: (id) => nomes[id] ?? 'Todas as filiais',
            rotulo: 'Filial',
            icone: Icons.storefront_outlined,
            aoMudar: (id) =>
                controller.mudarFilial(id == null || id == _todas ? null : id),
          ),
      ],
    );
  }
}
