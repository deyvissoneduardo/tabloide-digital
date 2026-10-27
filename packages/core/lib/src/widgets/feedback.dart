import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';
import 'package:tabloide_core/src/widgets/app_aviso.dart';

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

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String rotuloConfirmar,
  String rotuloCancelar = 'Cancelar',
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(rotuloCancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(rotuloConfirmar),
        ),
      ],
    ),
  );
  return confirmou ?? false;
}

void mostrarAviso(
  BuildContext context,
  String mensagem, {
  TipoAviso tipo = TipoAviso.sucesso,
  String? titulo,
  IconData? icone,
  Duration duracao = const Duration(seconds: 4),
  String? rotuloAcao,
  VoidCallback? aoAgir,
}) {
  final cores = Theme.of(context).colorScheme;
  final cor = tipo.cor(cores);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: cores.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRaios.bordaMd,
          side: BorderSide(color: cor),
        ),
        duration: duracao,
        content: AppAviso(
          mensagem: mensagem,
          tipo: tipo,
          titulo: titulo,
          icone: icone,
        ),
        action: switch ((rotuloAcao, aoAgir)) {
          (final rotulo?, final acao?) => SnackBarAction(
            label: rotulo,
            textColor: cor,
            onPressed: acao,
          ),
          _ => null,
        },
      ),
    );
}
