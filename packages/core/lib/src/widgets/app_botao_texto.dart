import 'package:flutter/material.dart';

class AppBotaoTexto extends StatelessWidget {
  const AppBotaoTexto({
    super.key,
    required this.rotulo,
    required this.aoPressionar,
  });

  final String rotulo;
  final VoidCallback? aoPressionar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return TextButton(
      onPressed: aoPressionar,
      child: Text(
        rotulo,
        style: tema.textTheme.titleMedium?.copyWith(
          color: tema.colorScheme.primary,
        ),
      ),
    );
  }
}
