import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_web/src/features/home/home_screen.dart';

class EscolherFilialScreen extends StatelessWidget {
  const EscolherFilialScreen({super.key});

  Future<void> _escolher(BuildContext context, FilialResponse filial) {
    context.read<FiliaisController>().usar(filial);
    return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filiais = context.watch<FiliaisController>().filiais;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Escolha a filial'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.larguraMaximaFormulario,
          ),
          child: ListView(
            padding: const EdgeInsets.all(AppEspacamentos.md),
            children: [
              Text(
                'Em qual filial você vai trabalhar agora?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppEspacamentos.md),
              for (final filial in filiais)
                AppCartaoFilial(
                  filial: filial,
                  aoTocar: () => _escolher(context, filial),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
