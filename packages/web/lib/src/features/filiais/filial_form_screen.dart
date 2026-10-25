import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_web/src/features/filiais/filial_form_controller.dart';
import 'package:tabloide_web/src/features/filiais/filial_form_estado.dart';
import 'package:tabloide_web/src/features/home/home_screen.dart';
import 'package:validatorless/validatorless.dart';

class FilialFormScreen extends StatefulWidget {
  const FilialFormScreen({super.key, this.filial, this.obrigatoria = false});

  final FilialResponse? filial;

  final bool obrigatoria;

  @override
  State<FilialFormScreen> createState() => _FilialFormScreenState();
}

class _FilialFormScreenState extends State<FilialFormScreen> {
  final _formulario = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.filial?.nome);
  late final _cep = TextEditingController(
    text: switch (widget.filial?.endereco.cep) {
      final cep? when cep.length == 8 => UtilBrasilFields.obterCep(
        cep,
        ponto: false,
      ),
      final cep => cep,
    },
  );
  late final _logradouro = TextEditingController(
    text: widget.filial?.endereco.logradouro,
  );
  late final _numero = TextEditingController(
    text: widget.filial?.endereco.numero,
  );
  late final _complemento = TextEditingController(
    text: widget.filial?.endereco.complemento,
  );
  late final _bairro = TextEditingController(
    text: widget.filial?.endereco.bairro,
  );
  late final _cidade = TextEditingController(
    text: widget.filial?.endereco.cidade,
  );
  late String? _uf = widget.filial?.endereco.uf;
  String? _cepBuscado;

  late final FilialFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<FilialFormController>();
  }

  @override
  void dispose() {
    _controller.reiniciar();
    for (final campo in [
      _nome,
      _cep,
      _logradouro,
      _numero,
      _complemento,
      _bairro,
      _cidade,
    ]) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _aoMudarCep(String valor) async {
    _controller.limparErroDoCampo('cep');
    final digitos = valor.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 8) {
      _cepBuscado = null;
      return;
    }
    if (digitos == _cepBuscado) return;
    _cepBuscado = digitos;
    final resultado = await _controller.buscarCep(digitos);
    if (!mounted || _cep.text.replaceAll(RegExp(r'\D'), '') != digitos) return;
    switch (resultado) {
      case Success(:final valor):
        _preencher(valor);
      case Failure(falha: FalhaApi(codigo: 'CEP_NAO_ENCONTRADO')):
        break;
      case Failure():
        mostrarAviso(
          context,
          'Não conseguimos buscar o CEP agora. Preencha o endereço à mão.',
          tipo: TipoAviso.alerta,
          titulo: 'CEP indisponível',
        );
    }
  }

  void _preencher(CepResponse endereco) {
    setState(() {
      for (final (campo, texto, valor) in [
        ('logradouro', _logradouro, endereco.logradouro),
        ('bairro', _bairro, endereco.bairro),
        ('cidade', _cidade, endereco.cidade),
      ]) {
        if (valor.isEmpty) continue;
        texto.text = valor;
        _controller.limparErroDoCampo(campo);
      }
      if (Uf.daSigla(endereco.uf) case final uf?) {
        _uf = uf.sigla;
        _controller.limparErroDoCampo('uf');
      }
    });
  }

  Future<void> _salvar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final controller = _controller;
    await controller.salvar(
      id: widget.filial?.id,
      nome: _nome.text,
      cep: _cep.text,
      logradouro: _logradouro.text,
      numero: _numero.text,
      complemento: _complemento.text,
      bairro: _bairro.text,
      cidade: _cidade.text,
      uf: _uf ?? '',
    );
    if (!mounted) return;
    switch (controller.estado) {
      case FilialFormConcluido(:final filial):
        context.read<FiliaisController>().salva(filial);
        if (widget.obrigatoria) {
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
            (_) => false,
          );
          return;
        }
        mostrarAviso(context, 'Filial salva.');
        Navigator.of(context).pop();
      case FilialFormComFalha(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case FilialFormOcioso() || FilialFormEnviando():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FilialFormController>();
    final enviando = controller.estado is FilialFormEnviando;
    return PopScope(
      canPop: !widget.obrigatoria,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.obrigatoria,
          title: Text(
            widget.obrigatoria
                ? 'Cadastre sua filial'
                : widget.filial == null
                ? 'Nova filial'
                : 'Editar filial',
          ),
        ),
        body: AppFormulario(
          chave: _formulario,
          children: [
            if (widget.obrigatoria) ...[
              Text(
                'Para começar, cadastre a primeira filial da sua loja.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppEspacamentos.md),
            ],
            AppCampoTexto(
              controller: _nome,
              rotulo: 'Nome da filial',
              icone: Icons.storefront_outlined,
              habilitado: !enviando,
              erro: controller.erroDoCampo('nome'),
              aoMudar: (_) => controller.limparErroDoCampo('nome'),
              validador: Validatorless.multiple([
                Validatorless.required('Informe o nome da filial.'),
                Validatorless.min(2, 'Mínimo de 2 caracteres.'),
              ]),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _cep,
              rotulo: 'CEP',
              icone: Icons.markunread_mailbox_outlined,
              habilitado: !enviando,
              teclado: TextInputType.number,
              autofill: const [AutofillHints.postalCode],
              erro: controller.erroDoCampo('cep'),
              aoMudar: _aoMudarCep,
              sufixo: controller.buscandoCep
                  ? const Padding(
                      padding: EdgeInsets.all(AppEspacamentos.md),
                      child: SizedBox.square(
                        dimension: AppIcones.pequeno,
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Buscando CEP',
                        ),
                      ),
                    )
                  : null,
              validador: Validatorless.multiple([
                Validatorless.required('Informe o CEP.'),
                (valor) => (valor ?? '').replaceAll('-', '').length == 8
                    ? null
                    : 'Digite um CEP com 8 números.',
              ]),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CepInputFormatter(ponto: false),
              ],
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _logradouro,
              rotulo: 'Rua ou avenida',
              icone: Icons.signpost_outlined,
              habilitado: !enviando,
              autofill: const [AutofillHints.streetAddressLine1],
              erro: controller.erroDoCampo('logradouro'),
              aoMudar: (_) => controller.limparErroDoCampo('logradouro'),
              validador: Validatorless.required('Informe a rua ou avenida.'),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _numero,
              rotulo: 'Número',
              icone: Icons.tag,
              habilitado: !enviando,
              erro: controller.erroDoCampo('numero'),
              aoMudar: (_) => controller.limparErroDoCampo('numero'),
              validador: Validatorless.required('Informe o número.'),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _complemento,
              rotulo: 'Complemento (opcional)',
              icone: Icons.apartment_outlined,
              habilitado: !enviando,
              autofill: const [AutofillHints.streetAddressLine2],
              erro: controller.erroDoCampo('complemento'),
              aoMudar: (_) => controller.limparErroDoCampo('complemento'),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _bairro,
              rotulo: 'Bairro',
              icone: Icons.map_outlined,
              habilitado: !enviando,
              erro: controller.erroDoCampo('bairro'),
              aoMudar: (_) => controller.limparErroDoCampo('bairro'),
              validador: Validatorless.required('Informe o bairro.'),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoTexto(
              controller: _cidade,
              rotulo: 'Cidade',
              icone: Icons.location_city_outlined,
              habilitado: !enviando,
              autofill: const [AutofillHints.addressCity],
              erro: controller.erroDoCampo('cidade'),
              aoMudar: (_) => controller.limparErroDoCampo('cidade'),
              validador: Validatorless.required('Informe a cidade.'),
            ),
            const SizedBox(height: AppEspacamentos.md),
            AppCampoSelecao<String>(
              valor: _uf,
              opcoes: [for (final uf in Uf.values) uf.sigla],
              rotuloDe: (uf) => uf,
              rotulo: 'UF',
              icone: Icons.flag_outlined,
              habilitado: !enviando,
              erro: controller.erroDoCampo('uf'),
              aoMudar: (uf) {
                controller.limparErroDoCampo('uf');
                setState(() => _uf = uf);
              },
              validador: Validatorless.required('Escolha a UF.'),
            ),
            const SizedBox(height: AppEspacamentos.md),
            const SizedBox(height: AppEspacamentos.lg),
            AppBotaoPrincipal(
              rotulo: 'Salvar filial',
              rotuloCarregando: 'Salvando',
              carregando: enviando,
              aoPressionar: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
