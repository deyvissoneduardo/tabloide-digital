import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/categorias/categorias_controller.dart';
import 'package:tabloide_app/src/features/produtos/produto_form_controller.dart';
import 'package:tabloide_app/src/features/produtos/produto_form_estado.dart';
import 'package:tabloide_app/src/features/produtos/produtos_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:validatorless/validatorless.dart';

const _ladoMaximoFoto = 1600.0;

String _preco(int? centavos) => switch (centavos) {
  final c? => Centavos.formatar(c),
  null => '',
};

class ProdutoFormScreen extends StatefulWidget {
  const ProdutoFormScreen({super.key, required this.filialId, this.produto});

  final String filialId;

  final ProdutoResponse? produto;

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formulario = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.produto?.nome);
  late final _promocional = TextEditingController(
    text: _preco(widget.produto?.precoPromocionalCentavos),
  );
  late final _original = TextEditingController(
    text: _preco(widget.produto?.precoOriginalCentavos),
  );
  late final _quantidade = TextEditingController(
    text: widget.produto?.quantidade,
  );
  late final _descricao = TextEditingController(
    text: widget.produto?.descricao,
  );
  late final _observacao = TextEditingController(
    text: widget.produto?.observacao,
  );
  late String? _categoriaId = widget.produto?.categoria.id;
  late DateTime? _inicio = widget.produto?.vigencia.dataInicio;
  late DateTime? _limite = widget.produto?.vigencia.dataLimite;

  late final ProdutoFormController _controller;

  bool get _novo => widget.produto == null;

  bool get _inicioTravado =>
      !(widget.produto?.vigencia.podeAlterarInicio ?? true);

  @override
  void initState() {
    super.initState();
    _controller = context.read<ProdutoFormController>();
  }

  @override
  void dispose() {
    _controller.reiniciar();
    for (final campo in [
      _nome,
      _promocional,
      _original,
      _quantidade,
      _descricao,
      _observacao,
    ]) {
      campo.dispose();
    }
    super.dispose();
  }

  String? _validarOriginal(String? texto) {
    final original = Centavos.ler(texto ?? '');
    final promocional = Centavos.ler(_promocional.text);
    if (original == null || promocional == null) return null;
    return original > promocional
        ? null
        : 'Precisa ser maior que o preço promocional.';
  }

  String? _validarLimite(DateTime? limite) => switch ((_inicio, limite)) {
    (final inicio?, final limite?) when limite.isBefore(inicio) =>
      'A data limite não pode ser anterior à data de início.',
    _ => null,
  };

  Future<void> _escolherFoto() async {
    final XFile? arquivo;
    try {
      arquivo = await context.read<ImagePicker>().pickImage(
        source: ImageSource.gallery,
        maxWidth: _ladoMaximoFoto,
        maxHeight: _ladoMaximoFoto,
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
    _controller.escolherFoto(await arquivo.readAsBytes(), arquivo.name);
  }

  Future<void> _salvar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final controller = _controller;
    await controller.salvar(
      filialId: widget.filialId,
      produto: widget.produto,
      request: ProdutoRequest(
        nome: _nome.text,
        categoriaId: _categoriaId!,
        precoPromocionalCentavos: Centavos.ler(_promocional.text)!,
        precoOriginalCentavos: Centavos.ler(_original.text),
        quantidade: _quantidade.text,
        descricao: _descricao.text,
        observacao: _observacao.text,
        dataInicio: _inicio,
        dataLimite: _limite,
      ),
    );
    if (!mounted) return;
    if (controller.estado case ProdutoFormComFalha(:final atualizado?)) {
      context.read<ProdutosController>().salvo(atualizado);
    }
    switch (controller.estado) {
      case ProdutoFormConcluido(:final produto):
        context.read<ProdutosController>().salvo(produto);
        mostrarAviso(context, _novo ? 'Produto publicado.' : 'Produto salvo.');
        Navigator.of(context).pop(produto);
      case ProdutoFormComFalha() when controller.temErroNosCampos:
        break;
      case ProdutoFormComFalha(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case ProdutoFormOcioso() || ProdutoFormEnviando():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProdutoFormController>();
    final categorias = context.watch<CategoriasController>().categorias;
    final enviando = controller.estado is ProdutoFormEnviando;
    final produto = widget.produto;
    final hoje = DataDia.hoje();
    final ultima = DateTime(hoje.year + 2, 12, 31);
    final inicio = _inicio;
    final urlFoto = controller.fotoRemovida ? null : produto?.urlFoto;
    final temFoto = controller.foto != null || urlFoto != null;
    final nomes = {for (final c in categorias) c.id: c.nome};
    final precoFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      CentavosInputFormatter(moeda: true),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(_novo ? 'Novo produto' : 'Editar produto')),
      body: AppFormulario(
        chave: _formulario,
        children: [
          AppCampoTexto(
            controller: _nome,
            rotulo: 'Nome do produto',
            icone: Icons.sell_outlined,
            habilitado: !enviando,
            erro: controller.erroDoCampo('nome'),
            aoMudar: (_) => controller.limparErroDoCampo('nome'),
            validador: Validatorless.multiple([
              Validatorless.required('Informe o nome do produto.'),
              Validatorless.max(120, 'Use até 120 caracteres.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoSelecao<String>(
            valor: nomes.containsKey(_categoriaId) ? _categoriaId : null,
            opcoes: nomes.keys.toList(),
            rotuloDe: (id) => nomes[id]!,
            rotulo: 'Categoria',
            icone: Icons.category_outlined,
            habilitado: !enviando,
            erro: controller.erroDoCampo('categoriaId'),
            validador: (id) => id == null ? 'Escolha a categoria.' : null,
            aoMudar: (id) {
              controller.limparErroDoCampo('categoriaId');
              setState(() => _categoriaId = id);
            },
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _promocional,
            rotulo: 'Preço promocional',
            icone: Icons.local_offer_outlined,
            habilitado: !enviando,
            teclado: TextInputType.number,
            inputFormatters: precoFormatters,
            erro: controller.erroDoCampo('precoPromocionalCentavos'),
            aoMudar: (_) =>
                controller.limparErroDoCampo('precoPromocionalCentavos'),
            validador: (texto) => switch (Centavos.ler(texto ?? '')) {
              null => 'Informe o preço promocional.',
              0 => 'O preço precisa ser maior que zero.',
              _ => null,
            },
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _original,
            rotulo: 'Preço original (opcional)',
            icone: Icons.money_off_outlined,
            habilitado: !enviando,
            teclado: TextInputType.number,
            inputFormatters: precoFormatters,
            erro: controller.erroDoCampo('precoOriginalCentavos'),
            aoMudar: (_) =>
                controller.limparErroDoCampo('precoOriginalCentavos'),
            validador: _validarOriginal,
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _quantidade,
            rotulo: 'Quantidade (opcional)',
            icone: Icons.scale_outlined,
            habilitado: !enviando,
            erro: controller.erroDoCampo('quantidade'),
            aoMudar: (_) => controller.limparErroDoCampo('quantidade'),
            validador: Validatorless.max(40, 'Use até 40 caracteres.'),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _descricao,
            rotulo: 'Descrição (opcional)',
            icone: Icons.notes_outlined,
            habilitado: !enviando,
            erro: controller.erroDoCampo('descricao'),
            aoMudar: (_) => controller.limparErroDoCampo('descricao'),
            validador: Validatorless.max(500, 'Use até 500 caracteres.'),
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoTexto(
            controller: _observacao,
            rotulo: 'Observação (opcional)',
            icone: Icons.info_outline,
            habilitado: !enviando,
            erro: controller.erroDoCampo('observacao'),
            aoMudar: (_) => controller.limparErroDoCampo('observacao'),
            validador: Validatorless.max(200, 'Use até 200 caracteres.'),
          ),
          const SizedBox(height: AppEspacamentos.lg),
          AppCampoImagem(
            rotulo: 'Foto do produto (opcional)',
            descricao: 'Foto do produto',
            bytes: controller.foto?.bytes,
            url: urlFoto,
            proporcao: 1,
            aoEscolher: enviando ? null : _escolherFoto,
            aoRemover: enviando || !temFoto ? null : controller.removerFoto,
            erro: controller.erroDoCampo('foto'),
            ajuda: 'JPEG, PNG ou WebP de até 10 MB.',
          ),
          const SizedBox(height: AppEspacamentos.lg),
          AppCampoData(
            rotulo: 'Data de início (opcional)',
            valor: inicio,
            primeiraData: hoje,
            ultimaData: ultima,
            habilitado: !enviando && !_inicioTravado,
            erro: controller.erroDoCampo('dataInicio'),
            dica: _inicioTravado
                ? 'Produto vigente: a data de início não muda mais.'
                : 'Sem data: começa hoje, ao publicar.',
            aoMudar: (data) {
              controller.limparErroDoCampo('dataInicio');
              setState(() => _inicio = data);
            },
            aoLimpar: _novo ? () => setState(() => _inicio = null) : null,
          ),
          const SizedBox(height: AppEspacamentos.md),
          AppCampoData(
            rotulo: 'Data limite (opcional)',
            valor: _limite,
            primeiraData: inicio != null && inicio.isAfter(hoje)
                ? inicio
                : hoje,
            ultimaData: ultima,
            habilitado: !enviando,
            erro: controller.erroDoCampo('dataLimite'),
            dica: 'Sem data: vale até ser excluído.',
            validador: _validarLimite,
            aoMudar: (data) {
              controller.limparErroDoCampo('dataLimite');
              setState(() => _limite = data);
            },
            aoLimpar: () {
              controller.limparErroDoCampo('dataLimite');
              setState(() => _limite = null);
            },
          ),
          const SizedBox(height: AppEspacamentos.lg),
          AppBotaoPrincipal(
            rotulo: _novo ? 'Publicar produto' : 'Salvar produto',
            rotuloCarregando: _novo ? 'Publicando' : 'Salvando',
            carregando: enviando,
            aoPressionar: _salvar,
          ),
        ],
      ),
    );
  }
}
