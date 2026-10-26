import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/src/features/panfletos/panfleto_form_controller.dart';
import 'package:tabloide_web/src/features/panfletos/panfleto_form_estado.dart';
import 'package:tabloide_web/src/features/panfletos/panfletos_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';

const _ladoMaximoPanfleto = 2400.0;

String _comConflito(String mensagem, Map<String, Object?> detalhes) {
  if (detalhes case {
    'conflitoCom': {
      'dataInicio': final String inicio,
      'dataLimite': final String? limite,
    },
  }) {
    try {
      final de = DataDia.completa(DataDia.ler(inicio));
      return switch (limite) {
        final limite? =>
          '$mensagem Ele conflita com o panfleto de $de a '
              '${DataDia.completa(DataDia.ler(limite))}.',
        null =>
          '$mensagem Ele conflita com o panfleto que começa em $de, '
              'sem data limite.',
      };
    } on FormatException {
      return mensagem;
    }
  }
  return mensagem;
}

class PanfletoFormScreen extends StatefulWidget {
  const PanfletoFormScreen({super.key, required this.filialId, this.panfleto});

  final String filialId;

  final PanfletoResponse? panfleto;

  @override
  State<PanfletoFormScreen> createState() => _PanfletoFormScreenState();
}

class _PanfletoFormScreenState extends State<PanfletoFormScreen> {
  final _formulario = GlobalKey<FormState>();
  late DateTime? _inicio = widget.panfleto?.vigencia.dataInicio;
  late DateTime? _limite = widget.panfleto?.vigencia.dataLimite;

  late final PanfletoFormController _controller;

  bool get _novo => widget.panfleto == null;

  bool get _inicioTravado =>
      !(widget.panfleto?.vigencia.podeAlterarInicio ?? true);

  @override
  void initState() {
    super.initState();
    _controller = context.read<PanfletoFormController>();
  }

  @override
  void dispose() {
    _controller.reiniciar();
    super.dispose();
  }

  String? _validarLimite(DateTime? limite) => switch ((_inicio, limite)) {
    (final inicio?, final limite?) when limite.isBefore(inicio) =>
      'A data limite não pode ser anterior à data de início.',
    _ => null,
  };

  Future<void> _escolherImagem() async {
    final XFile? arquivo;
    try {
      arquivo = await context.read<ImagePicker>().pickImage(
        source: ImageSource.gallery,
        maxWidth: _ladoMaximoPanfleto,
        maxHeight: _ladoMaximoPanfleto,
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
    _controller.escolherImagem(await arquivo.readAsBytes(), arquivo.name);
  }

  Future<void> _salvar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final controller = _controller;
    await controller.salvar(
      filialId: widget.filialId,
      panfleto: widget.panfleto,
      dataInicio: _inicio,
      dataLimite: _limite,
    );
    if (!mounted) return;
    if (controller.estado case PanfletoFormComFalha(:final atualizado?)) {
      context.read<PanfletosController>().salvo(atualizado);
    }
    switch (controller.estado) {
      case PanfletoFormConcluido(:final panfleto):
        context.read<PanfletosController>().salvo(panfleto);
        mostrarAviso(
          context,
          _novo ? 'Panfleto publicado.' : 'Panfleto salvo.',
        );
        Navigator.of(context).pop();
      case PanfletoFormComFalha(
        falha: FalhaApi(
          codigo: 'PANFLETO_ATUAL_SEM_DATA_LIMITE',
          :final mensagem,
        ),
      ):
        mostrarAviso(
          context,
          mensagem,
          tipo: TipoAviso.alerta,
          titulo: 'Defina a data limite',
        );
      case PanfletoFormComFalha(
        falha: FalhaApi(
          codigo: 'PANFLETO_PERIODO_SOBREPOSTO',
          :final mensagem,
          :final detalhes,
        ),
      ):
        mostrarAviso(
          context,
          _comConflito(mensagem, detalhes),
          tipo: TipoAviso.erro,
        );
      case PanfletoFormComFalha(falha: FalhaApi(:final campos))
          when campos.isNotEmpty:
        break;
      case PanfletoFormComFalha(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case PanfletoFormOcioso() || PanfletoFormEnviando():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PanfletoFormController>();
    final enviando = controller.estado is PanfletoFormEnviando;
    final panfleto = widget.panfleto;
    final hoje = DataDia.hoje();
    final ultima = DateTime(hoje.year + 2, 12, 31);
    final inicio = _inicio;
    return Scaffold(
      appBar: AppBar(title: Text(_novo ? 'Novo panfleto' : 'Editar panfleto')),
      body: AppFormulario(
        chave: _formulario,
        children: [
          AppCampoImagem(
            rotulo: 'Imagem do panfleto',
            descricao: 'Imagem do panfleto',
            bytes: controller.imagem?.bytes,
            url: panfleto?.urlImagem,
            proporcao: panfleto == null
                ? 3 / 4
                : panfleto.largura / panfleto.altura,
            aoEscolher: enviando ? null : _escolherImagem,
            erro: controller.erroDoCampo('imagem'),
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
                ? 'Panfleto vigente: a data de início não muda mais.'
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
            aoLimpar: panfleto?.vigencia.dataLimite == null
                ? () => setState(() => _limite = null)
                : null,
          ),
          const SizedBox(height: AppEspacamentos.lg),
          AppBotaoPrincipal(
            rotulo: _novo ? 'Publicar panfleto' : 'Salvar panfleto',
            rotuloCarregando: _novo ? 'Publicando' : 'Salvando',
            carregando: enviando,
            aoPressionar: _salvar,
          ),
        ],
      ),
    );
  }
}
