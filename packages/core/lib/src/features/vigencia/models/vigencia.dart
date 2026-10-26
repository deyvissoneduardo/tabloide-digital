import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';

final class Vigencia {
  const Vigencia({
    required this.dataInicio,
    required this.situacao,
    required this.editavel,
    this.dataLimite,
  });

  factory Vigencia.fromJson(Object? json) => switch (json) {
    {
      'dataInicio': final String dataInicio,
      'dataLimite': final String? dataLimite,
      'situacao': final String codigo,
      'editavel': final bool editavel,
    } =>
      Vigencia(
        dataInicio: DataDia.ler(dataInicio),
        dataLimite: dataLimite == null ? null : DataDia.ler(dataLimite),
        situacao: switch (SituacaoVigencia.doCodigo(codigo)) {
          final situacao? => situacao,
          null => throw FormatException('Situação desconhecida', codigo),
        },
        editavel: editavel,
      ),
    _ => throw const FormatException('Vigência fora do formato esperado'),
  };

  final DateTime dataInicio;

  final DateTime? dataLimite;

  final SituacaoVigencia situacao;

  final bool editavel;

  bool get podeAlterarInicio =>
      editavel && situacao == SituacaoVigencia.agendado;

  @override
  bool operator ==(Object other) =>
      other is Vigencia &&
      other.dataInicio == dataInicio &&
      other.dataLimite == dataLimite &&
      other.situacao == situacao &&
      other.editavel == editavel;

  @override
  int get hashCode => Object.hash(dataInicio, dataLimite, situacao, editavel);

  @override
  String toString() =>
      'Vigencia(${situacao.codigo}, ${DataDia.iso(dataInicio)} → '
      '${switch (dataLimite) {
        final limite? => DataDia.iso(limite),
        null => 'sem limite',
      }})';
}
