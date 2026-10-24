import 'package:flutter/material.dart';

class AppCampoTexto extends StatelessWidget {
  const AppCampoTexto({
    super.key,
    required this.controller,
    required this.rotulo,
    required this.icone,
    this.validador,
    this.habilitado = true,
    this.teclado,
    this.acao = TextInputAction.next,
    this.autofill,
    this.autocorrecao = true,
    this.erro,
    this.aoMudar,
    this.aoEnviar,
  });

  final TextEditingController controller;
  final String rotulo;
  final IconData icone;
  final FormFieldValidator<String>? validador;
  final bool habilitado;
  final TextInputType? teclado;
  final TextInputAction acao;
  final Iterable<String>? autofill;
  final bool autocorrecao;
  final String? erro;
  final ValueChanged<String>? aoMudar;
  final ValueChanged<String>? aoEnviar;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: habilitado,
    decoration: InputDecoration(labelText: rotulo, prefixIcon: Icon(icone)),
    keyboardType: teclado,
    textInputAction: acao,
    autocorrect: autocorrecao,
    autofillHints: autofill,
    forceErrorText: erro,
    onChanged: aoMudar,
    onFieldSubmitted: aoEnviar,
    validator: validador,
  );
}
