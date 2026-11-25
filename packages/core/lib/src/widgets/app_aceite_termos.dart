import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';

/// Caixa de aceite dos Termos de Uso e da Política de Privacidade (LGPD), com os dois nomes como links.
/// Participa do `Form`: o `validador` recebe o valor marcado; `erro` mostra o erro vindo da API.
class AppAceiteTermos extends StatefulWidget {
  const AppAceiteTermos({
    super.key,
    required this.aoMudar,
    required this.aoAbrirTermos,
    required this.aoAbrirPrivacidade,
    this.valorInicial = false,
    this.validador,
    this.habilitado = true,
    this.erro,
  });

  final ValueChanged<bool> aoMudar;
  final VoidCallback aoAbrirTermos;
  final VoidCallback aoAbrirPrivacidade;
  final bool valorInicial;
  final FormFieldValidator<bool>? validador;
  final bool habilitado;
  final String? erro;

  @override
  State<AppAceiteTermos> createState() => _AppAceiteTermosState();
}

class _AppAceiteTermosState extends State<AppAceiteTermos> {
  late final _termos = TapGestureRecognizer()
    ..onTap = () => widget.aoAbrirTermos();
  late final _privacidade = TapGestureRecognizer()
    ..onTap = () => widget.aoAbrirPrivacidade();

  @override
  void dispose() {
    _termos.dispose();
    _privacidade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estiloLink = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    return FormField<bool>(
      initialValue: widget.valorInicial,
      validator: widget.validador,
      forceErrorText: widget.erro,
      builder: (campo) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: campo.value ?? false,
                isError: campo.hasError,
                onChanged: widget.habilitado
                    ? (marcado) {
                        campo.didChange(marcado ?? false);
                        widget.aoMudar(marcado ?? false);
                      }
                    : null,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: tema.textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Li e aceito os '),
                      TextSpan(
                        text: 'Termos de Uso',
                        style: estiloLink,
                        recognizer: _termos,
                      ),
                      const TextSpan(text: ' e a '),
                      TextSpan(
                        text: 'Política de Privacidade',
                        style: estiloLink,
                        recognizer: _privacidade,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (campo.errorText case final erro?)
            Padding(
              padding: const EdgeInsets.only(left: AppEspacamentos.md),
              child: Text(
                erro,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
