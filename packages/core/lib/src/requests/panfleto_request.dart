import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';

final class PanfletoRequest {
  const PanfletoRequest({this.dataInicio, this.dataLimite});

  final DateTime? dataInicio;

  final DateTime? dataLimite;

  Map<String, String> toJson() => {
    if (dataInicio case final inicio?) 'dataInicio': DataDia.iso(inicio),
    if (dataLimite case final limite?) 'dataLimite': DataDia.iso(limite),
  };

  @override
  bool operator ==(Object other) =>
      other is PanfletoRequest &&
      other.dataInicio == dataInicio &&
      other.dataLimite == dataLimite;

  @override
  int get hashCode => Object.hash(dataInicio, dataLimite);

  @override
  String toString() =>
      'PanfletoRequest(dataInicio: $dataInicio, dataLimite: $dataLimite)';
}
