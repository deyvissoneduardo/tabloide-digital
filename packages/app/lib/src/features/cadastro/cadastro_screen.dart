import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/cadastro/cadastro_controller.dart';
import 'package:tabloide_app/src/features/cadastro/cadastro_estado.dart';
import 'package:tabloide_app/src/features/home/home_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:validatorless/validatorless.dart';

const _mensagemSenha =
    'A senha precisa ter de 8 a 128 caracteres, com ao menos uma letra e um número.';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formulario = GlobalKey<FormState>();
  final _nomeFantasia = TextEditingController();
  final _nomeResponsavel = TextEditingController();
  final _email = TextEditingController();
  final _whatsapp = TextEditingController();
  final _cnpj = TextEditingController();
  final _senha = TextEditingController();
  final _confirmarSenha = TextEditingController();

  late final CadastroController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<CadastroController>();
  }

  @override
  void dispose() {
    _controller.reiniciar();
    for (final campo in [
      _nomeFantasia,
      _nomeResponsavel,
      _email,
      _whatsapp,
      _cnpj,
      _senha,
      _confirmarSenha,
    ]) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final controller = _controller;
    await controller.cadastrar(
      nomeFantasia: _nomeFantasia.text,
      nomeResponsavel: _nomeResponsavel.text,
      email: _email.text,
      senha: _senha.text,
      whatsapp: _whatsapp.text,
      cnpj: _cnpj.text,
    );
    if (!mounted) return;
    switch (controller.estado) {
      case CadastroConcluido():
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      case CadastroComFalha(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case CadastroOcioso() || CadastroEnviando():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CadastroController>();
    final enviando = controller.estado is CadastroEnviando;
    return Scaffold(
      appBar: AppBar(title: const Text('Crie sua conta')),
      body: AppFormulario(
        chave: _formulario,
        children: [
          AppCampoTexto(
            controller: _nomeFantasia,
            rotulo: 'Nome fantasia',
            icone: Icons.storefront_outlined,
            habilitado: !enviando,
            autofill: const [AutofillHints.organizationName],
            erro: controller.erroDoCampo('nomeFantasia'),
            aoMudar: (_) => controller.limparErroDoCampo('nomeFantasia'),
            validador: Validatorless.multiple([
              Validatorless.required('Informe o nome fantasia.'),
              Validatorless.min(2, 'Mínimo de 2 caracteres.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _nomeResponsavel,
            rotulo: 'Nome do responsável',
            icone: Icons.person_outline,
            habilitado: !enviando,
            autofill: const [AutofillHints.name],
            erro: controller.erroDoCampo('nomeResponsavel'),
            aoMudar: (_) => controller.limparErroDoCampo('nomeResponsavel'),
            validador: Validatorless.multiple([
              Validatorless.required('Informe o nome do responsável.'),
              Validatorless.min(2, 'Mínimo de 2 caracteres.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _email,
            rotulo: 'E-mail',
            icone: Icons.email_outlined,
            habilitado: !enviando,
            teclado: TextInputType.emailAddress,
            autofill: const [AutofillHints.email],
            erro: controller.erroDoCampo('email'),
            aoMudar: (_) => controller.limparErroDoCampo('email'),
            validador: Validatorless.multiple([
              Validatorless.required('Informe o e-mail.'),
              Validatorless.email('Digite um e-mail válido.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _whatsapp,
            rotulo: 'WhatsApp (com DDD)',
            icone: Icons.phone_outlined,
            habilitado: !enviando,
            teclado: TextInputType.phone,
            autofill: const [AutofillHints.telephoneNumber],
            erro: controller.erroDoCampo('whatsapp'),
            aoMudar: (_) => controller.limparErroDoCampo('whatsapp'),
            validador: Validatorless.required('Informe o WhatsApp.'),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _cnpj,
            rotulo: 'CNPJ',
            icone: Icons.badge_outlined,
            habilitado: !enviando,
            erro: controller.erroDoCampo('cnpj'),
            aoMudar: (_) => controller.limparErroDoCampo('cnpj'),
            validador: Validatorless.required('Informe o CNPJ.'),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoSenha(
            controller: _senha,
            rotulo: 'Senha',
            habilitado: !enviando,
            autofill: const [AutofillHints.newPassword],
            erro: controller.erroDoCampo('senha'),
            aoMudar: (_) => controller.limparErroDoCampo('senha'),
            validador: Validatorless.multiple([
              Validatorless.required('Informe a senha.'),
              Validatorless.between(8, 128, _mensagemSenha),
              (valor) =>
                  RegExp(
                    r'^(?=.*\p{L})(?=.*\d)',
                    unicode: true,
                  ).hasMatch(valor ?? '')
                  ? null
                  : _mensagemSenha,
            ]),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoSenha(
            controller: _confirmarSenha,
            rotulo: 'Confirmar senha',
            habilitado: !enviando,
            acao: TextInputAction.done,
            autofill: const [AutofillHints.newPassword],
            aoEnviar: (_) => _cadastrar(),
            validador: Validatorless.multiple([
              Validatorless.required('Confirme a senha.'),
              Validatorless.compare(_senha, 'As senhas não conferem.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.lg),
          AppBotaoPrincipal(
            rotulo: 'Cadastrar',
            rotuloCarregando: 'Cadastrando',
            carregando: enviando,
            aoPressionar: _cadastrar,
          ),
        ],
      ),
    );
  }
}
