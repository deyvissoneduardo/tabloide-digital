import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/categorias/categoria_form_controller.dart';
import 'package:tabloide_app/src/features/categorias/categoria_form_estado.dart';
import 'package:tabloide_app/src/features/categorias/categorias_controller.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:validatorless/validatorless.dart';

class CategoriaFormScreen extends StatefulWidget {
  const CategoriaFormScreen({
    super.key,
    required this.filialId,
    this.categoria,
  });

  final String filialId;

  final CategoriaResponse? categoria;

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formulario = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.categoria?.nome);

  late final CategoriaFormController _controller;

  bool get _nova => widget.categoria == null;

  @override
  void initState() {
    super.initState();
    _controller = context.read<CategoriaFormController>();
  }

  @override
  void dispose() {
    _controller.reiniciar();
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final controller = _controller;
    await controller.salvar(
      filialId: widget.filialId,
      nome: _nome.text,
      categoria: widget.categoria,
    );
    if (!mounted) return;
    switch (controller.estado) {
      case CategoriaFormConcluido(:final categoria):
        context.read<CategoriasController>().salva(categoria);
        mostrarAviso(context, _nova ? 'Categoria criada.' : 'Categoria salva.');
        Navigator.of(context).pop();
      case CategoriaFormComFalha() when controller.erroNome != null:
        break;
      case CategoriaFormComFalha(:final falha):
        mostrarAviso(context, falha.mensagem, tipo: TipoAviso.erro);
      case CategoriaFormOcioso() || CategoriaFormEnviando():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CategoriaFormController>();
    final enviando = controller.estado is CategoriaFormEnviando;
    return Scaffold(
      appBar: AppBar(
        title: Text(_nova ? 'Nova categoria' : 'Renomear categoria'),
      ),
      body: AppFormulario(
        chave: _formulario,
        children: [
          AppCampoTexto(
            controller: _nome,
            rotulo: 'Nome da categoria',
            icone: Icons.category_outlined,
            habilitado: !enviando,
            acao: TextInputAction.done,
            erro: controller.erroNome,
            aoMudar: (_) => controller.limparErroNome(),
            aoEnviar: (_) => _salvar(),
            validador: Validatorless.multiple([
              Validatorless.required('Informe o nome da categoria.'),
              Validatorless.max(80, 'Use até 80 caracteres.'),
            ]),
          ),
          const SizedBox(height: AppEspacamentos.lg),
          AppBotaoPrincipal(
            rotulo: 'Salvar categoria',
            rotuloCarregando: 'Salvando',
            carregando: enviando,
            aoPressionar: _salvar,
          ),
        ],
      ),
    );
  }
}
