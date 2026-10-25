import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.inputFormatters,
    this.somenteLeitura = false,
    this.aoTocar,
    this.sufixo,
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
  final List<TextInputFormatter>? inputFormatters;
  final bool somenteLeitura;
  final VoidCallback? aoTocar;
  final Widget? sufixo;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: habilitado,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: Icon(icone),
        suffixIcon: sufixo,
      ),
      readOnly: somenteLeitura,
      onTap: aoTocar,
      keyboardType: teclado,
      textInputAction: acao,
      autocorrect: autocorrecao,
      autofillHints: autofill,
      forceErrorText: erro,
      onChanged: aoMudar,
      onFieldSubmitted: aoEnviar,
      validator: validador,
      inputFormatters: inputFormatters,
    );
  }
}
