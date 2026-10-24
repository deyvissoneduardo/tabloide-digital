import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';

class AppFormulario extends StatelessWidget {
  const AppFormulario({super.key, required this.chave, required this.children});

  final GlobalKey<FormState> chave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.larguraMaximaFormulario,
          ),
          child: Form(
            key: chave,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}
