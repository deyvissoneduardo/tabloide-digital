import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/identidade/identidade_controller.dart';
import 'package:tabloide_app/src/features/identidade/identidade_estado.dart';
import 'package:tabloide_app/src/features/login/login_controller.dart';
import 'package:tabloide_app/src/features/login/login_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:validatorless/validatorless.dart';

final _corHex = RegExp(r'^#[0-9A-F]{6}$');

const _ladoMaximoLogo = 1024.0;

String? _validarCor(String? valor) =>
    (valor ?? '').isEmpty || _corHex.hasMatch(valor!)
    ? null
    : 'Informe a cor no formato #RRGGBB.';

class IdentidadeScreen extends StatefulWidget {
  const IdentidadeScreen({super.key});

  @override
  State<IdentidadeScreen> createState() => _IdentidadeScreenState();
}

class _IdentidadeScreenState extends State<IdentidadeScreen> {
  final _formulario = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _corPrimaria = TextEditingController();
  final _corSecundaria = TextEditingController();

  late final IdentidadeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<IdentidadeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  @override
  void dispose() {
    _nome.dispose();
    _corPrimaria.dispose();
    _corSecundaria.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    await _controller.carregar();
    if (!mounted) return;
    if (_controller.estado case IdentidadeCarregada(:final identidade)) {
      _preencher(identidade);
    }
  }

  void _preencher(IdentidadeResponse identidade) {
    _nome.text = identidade.nomeFantasia;
    _corPrimaria.text = identidade.corPrimaria ?? '';
    _corSecundaria.text = identidade.corSecundaria ?? '';
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
      corPrimaria: _corPrimaria.text,
      corSecundaria: _corSecundaria.text,
    );
    if (!mounted) return;
    switch (resultado) {
      case Success(:final valor):
        _preencher(valor);
        mostrarAviso(context, 'Identidade visual salva.');
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
    final controller = context.watch<IdentidadeController>();
    final tema = Theme.of(context);
    final ocupado = controller.salvando || controller.enviandoLogo;
    return Scaffold(
      appBar: AppBar(title: const Text('Identidade visual')),
      body: switch (controller.estado) {
        IdentidadeCarregando() => const EsqueletoLista(),
        IdentidadeComFalha(:final falha) => EstadoFalha(
          mensagem: falha.mensagem,
          aoTentarDeNovo: _carregar,
        ),
        IdentidadeCarregada(:final identidade) => AppFormulario(
          chave: _formulario,
          children: [
            Text(
              'Vale para todas as filiais: o mesmo nome, logo e cores aparecem em todos os panfletos.',
              style: tema.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppEspacamentos.lg),
            Center(
              child: AppLogoIdentidade(
                url: identidade.urlLogo,
                nome: identidade.nomeFantasia,
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
