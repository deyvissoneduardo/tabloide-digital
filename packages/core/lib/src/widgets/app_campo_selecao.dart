import 'package:flutter/material.dart';

class AppCampoSelecao<T> extends StatelessWidget {
  const AppCampoSelecao({
    super.key,
    required this.valor,
    required this.opcoes,
    required this.rotuloDe,
    required this.rotulo,
    required this.icone,
    required this.aoMudar,
    this.validador,
    this.habilitado = true,
    this.erro,
  });

  final T? valor;
  final List<T> opcoes;
  final String Function(T opcao) rotuloDe;
  final String rotulo;
  final IconData icone;
  final ValueChanged<T?> aoMudar;
  final FormFieldValidator<T>? validador;
  final bool habilitado;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: rotulo, prefixIcon: Icon(icone)),
      forceErrorText: erro,
      validator: validador,
      onChanged: habilitado ? aoMudar : null,
      items: [
        for (final opcao in opcoes)
          DropdownMenuItem<T>(
            value: opcao,
            child: Text(rotuloDe(opcao), overflow: TextOverflow.ellipsis),
          ),
      ],
    );
  }
}
