import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../helpers/montar.dart';

class _Cartao extends StatelessWidget {
  const _Cartao();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppEspacamentos.md),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarcaLogo(),
        SizedBox(width: AppEspacamentos.sm),
        Flexible(child: MarcaNome()),
      ],
    ),
  );
}

void main() {
  goldenTest(
    'Cenário: Dado o tema claro, então mostra a logo e o nome do Tabloide Digital',
    fileName: 'marca_logo_nome',
    pumpBeforeTest: (tester) async {
      await precarregarLogo(tester);
      await tester.pumpAndSettle();
    },
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Tema claro',
          constraints: const BoxConstraints.tightFor(width: 260, height: 80),
          child: montarComMarca(const _Cartao()),
        ),
      ],
    ),
  );
}
