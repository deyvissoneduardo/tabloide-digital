import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/login/login_controller.dart';
import 'package:tabloide_app/src/features/login/login_screen.dart';
import 'package:tabloide_app/src/features/perfil/perfil_controller.dart';
import 'package:tabloide_app/src/features/perfil/perfil_estado.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:validatorless/validatorless.dart';

final _corHex = RegExp(r'^#[0-9A-F]{6}$');

final _naoDigito = RegExp(r'\D');

const _ladoMaximoLogo = 1024.0;

String? _validarCor(String? valor) =>
    (valor ?? '').isEmpty || _corHex.hasMatch(valor!)
    ? null
    : 'Informe a cor no formato #RRGGBB.';

String _mascarar(String texto, TextInputFormatter formatador) => formatador
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: texto))
    .text;

String _whatsappSemDdi(String whatsapp) {
  final digitos = whatsapp.replaceAll(_naoDigito, '');
  return digitos.length > 11 && digitos.startsWith('55')
      ? digitos.substring(2)
      : digitos;
}

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _nome = TextEditingController();
  final _responsavel = TextEditingController();
  final _whatsapp = TextEditingController();
  final _cnpj = TextEditingController();
  final _corPrimaria = TextEditingController();
  final _corSecundaria = TextEditingController();

  late final PerfilController _controller;

  bool _sePanfleto = false;

  @override
  void initState() {
    super.initState();
    _controller = context.read<PerfilController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  @override
  void dispose() {
    for (final campo in [
      _email,
      _nome,
      _responsavel,
      _whatsapp,
      _cnpj,
      _corPrimaria,
      _corSecundaria,
    ]) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _carregar() async {
    await _controller.carregar();
    if (!mounted) return;
    _preencher();
  }

  void _preencher() {
    if (_controller.estado case PerfilCarregado(
      :final lojista,
      :final identidade,
    )) {
      _email.text = lojista.email;
      _nome.text = lojista.nomeFantasia;
      _responsavel.text = lojista.nomeResponsavel;
      _whatsapp.text = _mascarar(
        _whatsappSemDdi(lojista.whatsapp),
        CelularInputFormatter(),
      );
      _cnpj.text = _mascarar(lojista.cnpj, CnpjAlfanumericoInputFormatter());
      _corPrimaria.text = identidade.corPrimaria ?? '';
      _corSecundaria.text = identidade.corSecundaria ?? '';
      setState(() => _sePanfleto = identidade.sePanfleto);
    }
  }

  Future<void> _trocarLogo() async {
    final XFile? arquivo;
    try {
      arquivo = await context.read<ImagePicker>().pickImage(
        source: ImageSource.gallery,
        maxWidth: _ladoMaximoLogo,
        maxHeight: _ladoMaximoLogo,
      );
    } on Exception {
      if (!mounted) return;
      mostrarAviso(
        context,
        'Não conseguimos abrir suas imagens. Verifique a permissão e tente de novo.',
        tipo: TipoAviso.erro,
      );
      return;
    }
    if (arquivo == null) return;
    final resultado = await _controller.enviarLogo(
      bytes: await arquivo.readAsBytes(),
      nomeArquivo: arquivo.name,
    );
    if (!mounted) return;
    switch (resultado) {
      case Success():
        mostrarAviso(context, 'Logo atualizado.');
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
    }
  }

  Future<void> _salvar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final resultado = await _controller.salvar(
      nomeFantasia: _nome.text,
      nomeResponsavel: _responsavel.text,
      whatsapp: _whatsapp.text,
      cnpj: _cnpj.text,
      corPrimaria: _corPrimaria.text,
      corSecundaria: _corSecundaria.text,
      sePanfleto: _sePanfleto,
    );
    if (!mounted) return;
    switch (resultado) {
      case Success():
        _preencher();
        mostrarAviso(context, 'Perfil salvo.');
      case Failure(falha: FalhaApi(:final campos)) when campos.isNotEmpty:
        break;
      case Failure(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
    }
  }

  Future<void> _sair() async {
    final confirmou = await confirmar(
      context,
      titulo: 'Sair do painel?',
      mensagem: 'Você vai precisar entrar de novo com e-mail e senha.',
      rotuloConfirmar: 'Sair',
    );
    if (!confirmou || !mounted) return;
    final navegador = Navigator.of(context);
    final filiais = context.read<FiliaisController>();
    final home = context.read<HomeController>();
    await context.read<LoginController>().sair();
    filiais.limpar();
    home.selecionar(SecaoPainel.inicio);
    await navegador.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PerfilController>();
    final tema = Theme.of(context);
    final ocupado = controller.salvando || controller.enviandoLogo;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: switch (controller.estado) {
        PerfilCarregando() => const EsqueletoLista(),
        PerfilComFalha(:final falha) => EstadoFalha(
          mensagem: falha.mensagem,
          aoTentarDeNovo: _carregar,
        ),
        PerfilCarregado(:final lojista, :final identidade) => AppFormulario(
          chave: _formulario,
          children: [
            Text('Dados da loja', style: tema.textTheme.titleMedium),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _email,
              rotulo: 'E-mail',
              icone: Icons.email_outlined,
              habilitado: false,
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _nome,
              rotulo: 'Nome fantasia',
              icone: Icons.storefront_outlined,
              habilitado: !ocupado,
              erro: controller.erroDoCampo('nomeFantasia'),
              aoMudar: (_) => controller.limparErroDoCampo('nomeFantasia'),
              validador: Validatorless.multiple([
                Validatorless.required('Informe o nome fantasia.'),
                Validatorless.min(2, 'Mínimo de 2 caracteres.'),
                Validatorless.max(120, 'Máximo de 120 caracteres.'),
              ]),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _responsavel,
              rotulo: 'Nome do responsável',
              icone: Icons.person_outline,
              habilitado: !ocupado,
              autofill: const [AutofillHints.name],
              erro: controller.erroDoCampo('nomeResponsavel'),
              aoMudar: (_) => controller.limparErroDoCampo('nomeResponsavel'),
              validador: Validatorless.multiple([
                Validatorless.required('Informe o nome do responsável.'),
                Validatorless.min(2, 'Mínimo de 2 caracteres.'),
                Validatorless.max(120, 'Máximo de 120 caracteres.'),
              ]),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _whatsapp,
              rotulo: 'WhatsApp (com DDD)',
              icone: Icons.phone_outlined,
              habilitado: !ocupado,
              teclado: TextInputType.phone,
              autofill: const [AutofillHints.telephoneNumber],
              erro: controller.erroDoCampo('whatsapp'),
              aoMudar: (_) => controller.limparErroDoCampo('whatsapp'),
              validador: Validatorless.required('Informe o WhatsApp.'),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CelularInputFormatter(),
              ],
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _cnpj,
              rotulo: 'CNPJ',
              icone: Icons.badge_outlined,
              habilitado: !ocupado,
              erro: controller.erroDoCampo('cnpj'),
              aoMudar: (_) => controller.limparErroDoCampo('cnpj'),
              validador: Validatorless.required('Informe o CNPJ.'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9a-zA-Z]')),
                CnpjAlfanumericoInputFormatter(),
              ],
            ),
            const SizedBox(height: AppEspacamentos.xl),
            Text('Identidade visual', style: tema.textTheme.titleMedium),
            const SizedBox(height: AppEspacamentos.xs),
            Text(
              'Vale para todas as filiais: o mesmo nome, logo e cores aparecem em todos os panfletos.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppEspacamentos.lg),
            Center(
              child: AppLogoIdentidade(
                url: identidade.urlLogo,
                nome: lojista.nomeFantasia,
              ),
            ),
            const SizedBox(height: AppEspacamentos.sm),
            Center(
              child: OutlinedButton.icon(
                onPressed: ocupado ? null : _trocarLogo,
                icon: controller.enviandoLogo
                    ? const SizedBox.square(
                        dimension: AppIcones.pequeno,
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Enviando logo',
                        ),
                      )
                    : const Icon(Icons.upload_outlined),
                label: Text(
                  controller.enviandoLogo ? 'Enviando logo' : 'Trocar logo',
                ),
              ),
            ),
            const SizedBox(height: AppEspacamentos.xs),
            Text(
              'JPEG, PNG ou WebP de até 10 MB.',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppEspacamentos.lg),
            AppSeletorCor(
              controller: _corPrimaria,
              rotulo: 'Cor primária',
              habilitado: !ocupado,
              erro: controller.erroDoCampo('corPrimaria'),
              aoMudar: (_) => controller.limparErroDoCampo('corPrimaria'),
              validador: _validarCor,
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppSeletorCor(
              controller: _corSecundaria,
              rotulo: 'Cor secundária',
              habilitado: !ocupado,
              erro: controller.erroDoCampo('corSecundaria'),
              aoMudar: (_) => controller.limparErroDoCampo('corSecundaria'),
              validador: _validarCor,
            ),
            const SizedBox(height: AppEspacamentos.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mostrar só o panfleto na página'),
              subtitle: const Text(
                'Vale para todas as filiais. Filial sem panfleto vigente mostra os produtos.',
              ),
              value: _sePanfleto,
              onChanged: ocupado
                  ? null
                  : (valor) => setState(() => _sePanfleto = valor),
            ),
            const SizedBox(height: AppEspacamentos.lg),
            AppBotaoPrincipal(
              rotulo: 'Salvar',
              rotuloCarregando: 'Salvando',
              carregando: controller.salvando,
              aoPressionar: controller.enviandoLogo ? null : _salvar,
            ),
            const SizedBox(height: AppEspacamentos.xl),
            const Divider(),
            const SizedBox(height: AppEspacamentos.sm),
            TextButton.icon(
              onPressed: ocupado ? null : _sair,
              icon: const Icon(Icons.logout),
              label: const Text('Sair do painel'),
            ),
          ],
        ),
      },
    );
  }
}
