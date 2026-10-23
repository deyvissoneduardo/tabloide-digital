import 'package:flutter/material.dart';

/// Pede confirmação antes de uma exclusão (RN12, RN20).
///
/// O botão de confirmar usa a cor de erro e repete o nome da ação
/// ([rotuloConfirmar], ex.: "Excluir filial"); [mensagem] descreve o impacto
/// (ex.: "Panfleto, categorias e produtos desta filial também serão
/// excluídos."). Devolve `true` só se o lojista confirmar.
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

/// Tipo do aviso mostrado em [mostrarAviso].
enum TipoAviso {
  /// Ação concluída (ex.: "Produto salvo").
  sucesso,

  /// Ação falhou (ex.: mensagem da `Falha` ao salvar).
  erro,
}

/// Retorno de uma ação em SnackBar. Erros de validação de campo NÃO usam
/// isto: aparecem no próprio campo (`errorText`/`validator`).
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
