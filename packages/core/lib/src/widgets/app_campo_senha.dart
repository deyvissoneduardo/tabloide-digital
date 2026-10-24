import 'package:flutter/material.dart';

class AppCampoSenha extends StatefulWidget {
  const AppCampoSenha({
    super.key,
    required this.controller,
    required this.rotulo,
    this.validador,
    this.habilitado = true,
    this.acao = TextInputAction.next,
    this.autofill,
    this.erro,
    this.aoMudar,
    this.aoEnviar,
  });

  final TextEditingController controller;
  final String rotulo;
  final FormFieldValidator<String>? validador;
  final bool habilitado;
  final TextInputAction acao;
  final Iterable<String>? autofill;
  final String? erro;
  final ValueChanged<String>? aoMudar;
  final ValueChanged<String>? aoEnviar;

  @override
  State<AppCampoSenha> createState() => _AppCampoSenhaState();
}

class _AppCampoSenhaState extends State<AppCampoSenha> {
  var _visivel = false;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    enabled: widget.habilitado,
    obscureText: !_visivel,
    decoration: InputDecoration(
      labelText: widget.rotulo,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        tooltip: _visivel ? 'Ocultar senha' : 'Mostrar senha',
        icon: Icon(
          _visivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        onPressed: () => setState(() => _visivel = !_visivel),
      ),
    ),
    textInputAction: widget.acao,
    autofillHints: widget.autofill,
    forceErrorText: widget.erro,
    onChanged: widget.aoMudar,
    onFieldSubmitted: widget.aoEnviar,
    validator: widget.validador,
  );
}
