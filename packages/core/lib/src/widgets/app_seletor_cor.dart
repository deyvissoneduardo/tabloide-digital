import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

const _larguraMaximaPaleta = 300.0;

class AppSeletorCor extends StatelessWidget {
  const AppSeletorCor({
    super.key,
    required this.controller,
    required this.rotulo,
    this.validador,
    this.erro,
    this.habilitado = true,
    this.aoMudar,
  });

  final TextEditingController controller;
  final String rotulo;
  final FormFieldValidator<String>? validador;
  final String? erro;
  final bool habilitado;
  final ValueChanged<String>? aoMudar;

  Future<void> _escolher(BuildContext context) async {
    final escolhida = await showDialog<Color>(
      context: context,
      builder: (_) => _DialogoCor(
        titulo: rotulo,
        inicial:
            colorFromHex(controller.text, enableAlpha: false) ??
            Theme.of(context).colorScheme.primary,
      ),
    );
    if (escolhida == null) return;
    controller.text = colorToHex(
      escolhida,
      includeHashSign: true,
      enableAlpha: false,
    );
    aoMudar?.call(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: habilitado,
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: '#RRGGBB',
        prefixIcon: _AmostraCor(controller: controller),
        suffixIcon: IconButton(
          tooltip: 'Escolher $rotulo',
          icon: const Icon(Icons.palette_outlined),
          onPressed: habilitado ? () => _escolher(context) : null,
        ),
      ),
      autocorrect: false,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: const [_FormatoHex()],
      forceErrorText: erro,
      onChanged: aoMudar,
      validator: validador,
    );
  }
}

class _AmostraCor extends StatelessWidget {
  const _AmostraCor({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Center(
        widthFactor: 1,
        child: Container(
          width: AppIcones.padrao,
          height: AppIcones.padrao,
          decoration: BoxDecoration(
            color:
                colorFromHex(controller.text, enableAlpha: false) ??
                Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: cores.outline),
          ),
        ),
      ),
    );
  }
}

class _DialogoCor extends StatefulWidget {
  const _DialogoCor({required this.titulo, required this.inicial});

  final String titulo;
  final Color inicial;

  @override
  State<_DialogoCor> createState() => _DialogoCorState();
}

class _DialogoCorState extends State<_DialogoCor> {
  late Color _cor = widget.inicial;

  @override
  Widget build(BuildContext context) {
    final largura = math.min(
      _larguraMaximaPaleta,
      MediaQuery.sizeOf(context).width - AppEspacamentos.xl * 4,
    );
    return AlertDialog(
      title: Text(widget.titulo),
      scrollable: true,
      content: ColorPicker(
        pickerColor: _cor,
        onColorChanged: (cor) => setState(() => _cor = cor),
        enableAlpha: false,
        labelTypes: const [],
        portraitOnly: true,
        colorPickerWidth: largura,
        pickerAreaBorderRadius: AppRaios.bordaSm,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_cor),
          child: const Text('Usar cor'),
        ),
      ],
    );
  }
}

final _naoHex = RegExp('[^0-9A-F]');

class _FormatoHex extends TextInputFormatter {
  const _FormatoHex();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.toUpperCase().replaceAll(_naoHex, '');
    final texto = digitos.isEmpty
        ? ''
        : '#${digitos.substring(0, math.min(6, digitos.length))}';
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
