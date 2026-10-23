import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_brands/tabloide_brands.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Amostra de uma marca: o que o cliente aprova quando entra no white-label.
class _Amostra extends StatelessWidget {
  const _Amostra();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            MarcaLogo(altura: 40),
            SizedBox(width: AppEspacamentos.sm),
            Expanded(child: MarcaNome()),
          ],
        ),
        const SizedBox(height: AppEspacamentos.md),
        Row(
          children: [
            FilledButton(onPressed: () {}, child: const Text('Primária')),
            const SizedBox(width: AppEspacamentos.sm),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              onPressed: () {},
              child: const Text('Secundária'),
            ),
          ],
        ),
      ],
    ),
  );
}

void main() {
  final registry = BrandRegistry();
  registrarMarcas(registry);

  goldenTest(
    'Cenário: Dado todas as marcas registradas, então a cartela mostra logo, nome e cores de cada uma',
    fileName: 'cartela_marcas',
    pumpBeforeTest: precacheImages,
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final id in registry.ids)
          GoldenTestScenario(
            name: id,
            constraints: const BoxConstraints.tightFor(width: 320, height: 140),
            child: Provider<BrandConfig>.value(
              value: registry.resolver(id),
              child: Builder(
                builder: (context) {
                  final marca = context.read<BrandConfig>();
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.claro(marca),
                    home: const Scaffold(body: _Amostra()),
                  );
                },
              ),
            ),
          ),
      ],
    ),
  );
}
