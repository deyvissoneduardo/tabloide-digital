import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

const _marcas = {
  'azul': MarcaFake(nome: 'Marca Azul'),
  'vermelha': MarcaFake(
    nome: 'Marca Vermelha',
    corPrimaria: Color(0xFFC62828),
    corSecundaria: Color(0xFF2E7D32),
  ),
};

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
    'Cenário: Dado duas marcas, então logo e nome seguem a marca no claro e no escuro',
    fileName: 'marca_logo_nome',
    pumpBeforeTest: (tester) async => tester.pumpAndSettle(),
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in _marcas.entries)
          for (final brilho in Brightness.values)
            GoldenTestScenario(
              name: 'Marca $nome, ${brilho.name}',
              constraints: const BoxConstraints.tightFor(
                width: 260,
                height: 80,
              ),
              child: montarComMarca(
                const _Cartao(),
                marca: marca,
                brilho: brilho,
              ),
            ),
      ],
    ),
  );
}
