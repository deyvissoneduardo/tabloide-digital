import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/home/home_screen.dart';
import 'package:tabloide_app/src/features/login/login_controller.dart';
import 'package:tabloide_app/src/features/login/login_estado.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:validatorless/validatorless.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  var _senhaVisivel = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final controller = context.read<LoginController>();
    await controller.entrar(email: _email.text, senha: _senha.text);
    if (!mounted) return;
    switch (controller.estado) {
      case LoginConcluido():
        unawaited(
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          ),
        );
      case LoginComFalha(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case LoginOcioso() || LoginEnviando():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final enviando = context.watch<LoginController>().estado is LoginEnviando;
    final cores = tema.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppEspacamentos.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.larguraMaximaFormulario,
              ),
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: MarcaLogo(altura: AppIcones.destaque)),
                    const SizedBox(height: AppEspacamentos.sm),
                    const Center(child: MarcaNome()),
                    const SizedBox(height: AppEspacamentos.lg),
                    Text('Entre no painel', style: tema.textTheme.titleMedium),
                    const SizedBox(height: AppEspacamentos.md),
                    TextFormField(
                      controller: _email,
                      enabled: !enviando,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      validator: Validatorless.multiple([
                        Validatorless.required('Informe o e-mail'),
                        Validatorless.email('Digite um e-mail válido.'),
                      ]),
                    ),
                    const SizedBox(height: AppEspacamentos.md),
                    TextFormField(
                      controller: _senha,
                      enabled: !enviando,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _senhaVisivel
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _entrar(),
                      validator: Validatorless.multiple([
                        Validatorless.required('Informe a senha.'),
                        Validatorless.min(6, 'Minimo de 6 caracters.'),
                      ]),
                    ),
                    const SizedBox(height: AppEspacamentos.lg),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cores.primary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRaios.bordaMd,
                        ),
                      ),
                      onPressed: enviando ? null : _entrar,
                      child: enviando
                          ? SizedBox.square(
                              dimension: AppIcones.padrao,
                              child: CircularProgressIndicator(
                                semanticsLabel: 'Entrando',
                                color: cores.secondary,
                              ),
                            )
                          : Text(
                              'Entrar',
                              style: tema.textTheme.titleMedium?.copyWith(
                                color: cores.onPrimary,
                              ),
                            ),
                    ),
                    const SizedBox(height: AppEspacamentos.sm),
                    Align(
                      alignment: AlignmentGeometry.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Cadastre - se ',
                          style: tema.textTheme.titleMedium?.copyWith(
                            color: cores.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
