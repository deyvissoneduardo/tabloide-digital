import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/pagina/edicao_aparencia.dart';
import 'package:tabloide_app/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:validatorless/validatorless.dart';

final _corHex = RegExp(r'^#[0-9A-F]{6}$');

const _maxBytesImagem = 10 * 1024 * 1024;

const _ladoMaximoLogo = 1024.0;

const _larguraMaximaFoto = 1600.0;

const _maxNomeBanner = 120;

String? _validarCor(String? valor) =>
    (valor ?? '').isEmpty || _corHex.hasMatch(valor!)
    ? null
    : 'Informe a cor no formato #RRGGBB.';

/// Seletores da seção "Cores", na ordem da tela (fundoBanner e categoria
/// ficam nas seções Banner e Categorias).
const _coresGerais = [
  (CorPagina.primaria, 'Cor primária'),
  (CorPagina.secundaria, 'Cor secundária'),
  (CorPagina.texto, 'Cor do texto'),
  (CorPagina.textoSuave, 'Cor do texto suave'),
  (CorPagina.fundoCartao, 'Fundo do cartão'),
  (CorPagina.fundoPagina, 'Fundo da página'),
  (CorPagina.neutra, 'Cor neutra'),
  (CorPagina.sobreCor, 'Texto sobre cor'),
];

/// Padrão de cada cor (plano.md §4.4), mostrado como dica.
String _ajudaDa(CorPagina cor) => switch (cor) {
  CorPagina.fundoBanner || CorPagina.categoria => 'Vazio usa a cor primária.',
  _ =>
    'Vazio usa o padrão ${AppCoresPagina.paraHex(switch (cor) {
      CorPagina.secundaria => AppCoresPagina.padraoSecundaria,
      CorPagina.texto => AppCoresPagina.padraoTexto,
      CorPagina.textoSuave => AppCoresPagina.padraoTextoSuave,
      CorPagina.fundoCartao => AppCoresPagina.padraoFundoCartao,
      CorPagina.fundoPagina => AppCoresPagina.padraoFundoPagina,
      CorPagina.neutra => AppCoresPagina.padraoNeutra,
      CorPagina.sobreCor => AppCoresPagina.padraoSobreCor,
      _ => AppCoresPagina.padraoPrimaria,
    })}.',
};

/// Aba "Aparência" da seção Página (RN46–RN48): banner, nome da categoria e
/// as 10 cores. Cada mudança vai para `PaginaController.aparenciaEmEdicao`
/// (prévia ao vivo); nada é salvo antes de "Publicar" (U16).
class AparenciaPagina extends StatefulWidget {
  const AparenciaPagina({super.key});

  @override
  State<AparenciaPagina> createState() => _AparenciaPaginaState();
}

class _AparenciaPaginaState extends State<AparenciaPagina> {
  late final PaginaController _controller;
  late final TextEditingController _nome;
  late final TextEditingController _descricao;
  late final Map<CorPagina, TextEditingController> _cores;

  @override
  void initState() {
    super.initState();
    _controller = context.read<PaginaController>();
    final edicao = _controller.aparenciaEmEdicao;
    _nome = TextEditingController(text: edicao.nomeBanner);
    _descricao = TextEditingController(text: edicao.descricao);
    _cores = {
      for (final cor in CorPagina.values)
        cor: TextEditingController(text: edicao.cores[cor]),
    };
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    for (final campo in _cores.values) {
      campo.dispose();
    }
    super.dispose();
  }

  void _editar(EdicaoAparencia Function(EdicaoAparencia) editar) =>
      _controller.editarAparencia(editar);

  void _mudarCor(CorPagina cor, String valor) {
    if (valor.isEmpty) {
      _editar((e) => e.comCor(cor, null));
    } else if (_corHex.hasMatch(valor)) {
      _editar((e) => e.comCor(cor, valor));
    }
  }

  Future<ImagemPendente?> _escolherImagem({
    required double maxLargura,
    required double maxAltura,
  }) async {
    final XFile? arquivo;
    try {
      arquivo = await context.read<ImagePicker>().pickImage(
        source: ImageSource.gallery,
        maxWidth: maxLargura,
        maxHeight: maxAltura,
      );
    } on Exception {
      if (!mounted) return null;
      mostrarAviso(
        context,
        'Não conseguimos abrir suas imagens. Verifique a permissão e tente de novo.',
        tipo: TipoAviso.erro,
      );
      return null;
    }
    if (arquivo == null) return null;
    final bytes = await arquivo.readAsBytes();
    if (!mounted) return null;
    if (bytes.length > _maxBytesImagem) {
      mostrarAviso(
        context,
        'A imagem passa de 10 MB. Escolha uma menor.',
        tipo: TipoAviso.erro,
      );
      return null;
    }
    return ImagemPendente(bytes: bytes, nomeArquivo: arquivo.name);
  }

  Future<void> _escolherLogo() async {
    final logo = await _escolherImagem(
      maxLargura: _ladoMaximoLogo,
      maxAltura: _ladoMaximoLogo,
    );
    if (logo != null) _editar((e) => e.comLogo(logo));
  }

  Future<void> _escolherFoto() async {
    final foto = await _escolherImagem(
      maxLargura: _larguraMaximaFoto,
      maxAltura: _larguraMaximaFoto,
    );
    if (foto != null) _editar((e) => e.comFoto(foto));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaginaController>();
    final edicao = controller.aparenciaEmEdicao;
    final habilitado = !controller.bloqueado && !controller.publicando;
    final texto = Theme.of(context).textTheme;
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        children: [
          Text('Banner', style: texto.titleMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mostrar banner'),
            subtitle: const Text(
              'Substitui o cabeçalho da página. Não aparece quando a página mostra só o panfleto.',
            ),
            value: edicao.exibirBanner,
            onChanged: habilitado
                ? (valor) => _editar((e) => e.comExibirBanner(valor))
                : null,
          ),
          if (edicao.exibirBanner) ...[
            const SizedBox(height: AppEspacamentos.sm),
            AppSeletorCor(
              controller: _cores[CorPagina.fundoBanner]!,
              rotulo: 'Cor do banner',
              ajuda: _ajudaDa(CorPagina.fundoBanner),
              habilitado: habilitado,
              validador: _validarCor,
              aoMudar: (v) => _mudarCor(CorPagina.fundoBanner, v),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoImagem(
              rotulo: 'Logo do banner',
              descricao: 'Logo do banner',
              bytes: edicao.bytesLogo,
              url: edicao.urlLogo,
              proporcao: 1,
              ajuda: 'Opcional. JPEG, PNG ou WebP de até 10 MB.',
              aoEscolher: habilitado ? _escolherLogo : null,
              aoRemover: habilitado ? () => _editar((e) => e.semLogo()) : null,
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _nome,
              rotulo: 'Nome do banner',
              icone: Icons.title_outlined,
              habilitado: habilitado,
              validador: Validatorless.max(
                _maxNomeBanner,
                'Máximo de $_maxNomeBanner caracteres.',
              ),
              aoMudar: (v) => _editar((e) => e.comNomeBanner(v)),
            ),
            const SizedBox(height: AppEspacamentos.lg),
            AppCampoCampanha(
              tipo: edicao.tipoCampanha,
              descricao: _descricao,
              bytesFoto: edicao.bytesFoto,
              urlFoto: edicao.urlFoto,
              habilitado: habilitado,
              aoMudarTipo: (tipo) => _editar((e) => e.comTipoCampanha(tipo)),
              aoEscolherFoto: _escolherFoto,
              aoRemoverFoto: () => _editar((e) => e.semFoto()),
              aoMudarDescricao: (v) => _editar((e) => e.comDescricao(v)),
              validadorDescricao: Validatorless.max(
                maxDescricaoCampanha,
                'Máximo de $maxDescricaoCampanha caracteres.',
              ),
            ),
          ],
          const SizedBox(height: AppEspacamentos.lg),
          const Divider(),
          const SizedBox(height: AppEspacamentos.md),
          Text('Categorias', style: texto.titleMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mostrar nome da categoria'),
            subtitle: const Text(
              'Desligado, os produtos aparecem numa grade única, na mesma ordem.',
            ),
            value: edicao.exibirNomeCategoria,
            onChanged: habilitado
                ? (valor) => _editar((e) => e.comExibirNomeCategoria(valor))
                : null,
          ),
          if (edicao.exibirNomeCategoria) ...[
            const SizedBox(height: AppEspacamentos.sm),
            AppSeletorCor(
              controller: _cores[CorPagina.categoria]!,
              rotulo: 'Cor do nome da categoria',
              ajuda: _ajudaDa(CorPagina.categoria),
              habilitado: habilitado,
              validador: _validarCor,
              aoMudar: (v) => _mudarCor(CorPagina.categoria, v),
            ),
          ],
          const SizedBox(height: AppEspacamentos.lg),
          const Divider(),
          const SizedBox(height: AppEspacamentos.md),
          Text('Cores', style: texto.titleMedium),
          const SizedBox(height: AppEspacamentos.xs),
          Text(
            'Usadas exatamente como escolhidas. Confira na prévia se o texto fica legível.',
            style: texto.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          for (final (cor, rotulo) in _coresGerais) ...[
            const SizedBox(height: AppEspacamentos.md),
            AppSeletorCor(
              controller: _cores[cor]!,
              rotulo: rotulo,
              ajuda: _ajudaDa(cor),
              habilitado: habilitado,
              validador: _validarCor,
              aoMudar: (v) => _mudarCor(cor, v),
            ),
          ],
        ],
      ),
    );
  }
}
