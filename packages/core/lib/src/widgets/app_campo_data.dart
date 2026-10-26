import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';

class AppCampoData extends StatelessWidget {
  const AppCampoData({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.primeiraData,
    required this.ultimaData,
    required this.aoMudar,
    this.aoLimpar,
    this.validador,
    this.habilitado = true,
    this.erro,
    this.dica,
    this.icone = Icons.event_outlined,
  });

  final String rotulo;
  final DateTime? valor;
  final DateTime primeiraData;
  final DateTime ultimaData;
  final ValueChanged<DateTime> aoMudar;
  final VoidCallback? aoLimpar;
  final FormFieldValidator<DateTime>? validador;
  final bool habilitado;
  final String? erro;
  final String? dica;
  final IconData icone;

  String _formatar(DateTime? data) =>
      data == null ? '' : DataDia.completa(data);

  Future<void> _escolher(BuildContext context) async {
    final primeira = DataDia.de(primeiraData);
    final ultima = DataDia.de(ultimaData);
    final atual = valor ?? primeira;
    final data = await showDatePicker(
      context: context,
      initialDate: atual.isBefore(primeira)
          ? primeira
          : atual.isAfter(ultima)
          ? ultima
          : atual,
      firstDate: primeira,
      lastDate: ultima,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: rotulo,
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );
    if (data != null) aoMudar(DataDia.de(data));
  }

  @override
  Widget build(BuildContext context) {
    final aoLimpar = this.aoLimpar;
    final validador = this.validador;
    return TextFormField(
      key: ValueKey(valor),
      initialValue: _formatar(valor),
      enabled: habilitado,
      readOnly: true,
      onTap: habilitado ? () => _escolher(context) : null,
      decoration: InputDecoration(
        labelText: rotulo,
        helperText: dica,
        helperMaxLines: 2,
        prefixIcon: Icon(icone),
        suffixIcon: aoLimpar != null && valor != null
            ? IconButton(
                tooltip: 'Limpar ${rotulo.toLowerCase()}',
                icon: const Icon(Icons.close),
                onPressed: habilitado ? aoLimpar : null,
              )
            : null,
      ),
      forceErrorText: erro,
      validator: validador == null ? null : (_) => validador(valor),
    );
  }
}
