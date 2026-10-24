import 'package:flutter/material.dart';

Future<bool> confirmarExclusao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String rotuloConfirmar,
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) {
      final cores = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cores.error,
              foregroundColor: cores.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(rotuloConfirmar),
          ),
        ],
      );
    },
  );
  return confirmou ?? false;
}

enum TipoAviso { sucesso, erro }

void mostrarAviso(
  BuildContext context,
  String mensagem, {
  TipoAviso tipo = TipoAviso.sucesso,
}) {
  final cores = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: switch (tipo) {
          TipoAviso.sucesso => null,
          TipoAviso.erro => cores.error,
        },
      ),
    );
}
