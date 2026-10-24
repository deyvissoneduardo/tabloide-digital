import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/cadastro/cadastro_screen.dart';
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
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        );
      case LoginComFalha(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case LoginOcioso() || LoginEnviando():
        break;
    }
  }

  Future<void> _abrirCadastro() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const CadastroScreen()));

  @override
  Widget build(BuildContext context) {
    final enviando = context.watch<LoginController>().estado is LoginEnviando;
    return Scaffold(
      body: AppFormulario(
        chave: _formulario,
        children: [
          const AppMarcaDestaque(),
          const SizedBox(height: AppEspacamentos.lg),
          Text(
            'Entre no painel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _email,
            rotulo: 'E-mail',
            icone: Icons.email_outlined,
            habilitado: !enviando,
            teclado: TextInputType.emailAddress,
            autocorrecao: false,
            autofill: const [AutofillHints.email],
            validador: Validatorless.multiple([
              Validatorless.required('Informe o e-mail'),
              Validatorless.email('Digite um e-mail válido.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoSenha(
            controller: _senha,
            rotulo: 'Senha',
            habilitado: !enviando,
            acao: TextInputAction.done,
            autofill: const [AutofillHints.password],
            aoEnviar: (_) => _entrar(),
            validador: Validatorless.multiple([
              Validatorless.required('Informe a senha.'),
              Validatorless.min(6, 'Minimo de 6 caracters.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.lg),
          AppBotaoPrincipal(
            rotulo: 'Entrar',
            rotuloCarregando: 'Entrando',
            carregando: enviando,
            aoPressionar: _entrar,
          ),
          const SizedBox(height: AppEspacamentos.sm),
          Align(
            alignment: AlignmentGeometry.centerRight,
            child: AppBotaoTexto(
              rotulo: 'Cadastre - se ',
              aoPressionar: enviando ? null : _abrirCadastro,
            ),
          ),
        ],
      ),
    );
  }
}
