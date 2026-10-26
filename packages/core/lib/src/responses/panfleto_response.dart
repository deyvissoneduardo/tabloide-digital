import 'package:tabloide_core/src/features/vigencia/models/vigencia.dart';

final class PanfletoResponse {
  const PanfletoResponse({
    required this.id,
    required this.filialId,
    required this.urlImagem,
    required this.largura,
    required this.altura,
    required this.vigencia,
    required this.criadoEm,
    this.excluidoEm,
  });

  factory PanfletoResponse.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'filialId': final String filialId,
      'urlImagem': final String urlImagem,
      'largura': final int largura,
      'altura': final int altura,
      'criadoEm': final String criadoEm,
      'excluidoEm': final String? excluidoEm,
    } =>
      PanfletoResponse(
        id: id,
        filialId: filialId,
        urlImagem: urlImagem,
        largura: largura,
        altura: altura,
        vigencia: Vigencia.fromJson(json),
        criadoEm: DateTime.parse(criadoEm),
        excluidoEm: excluidoEm == null ? null : DateTime.parse(excluidoEm),
      ),
    _ => throw const FormatException('Panfleto fora do formato esperado'),
  };

  final String id;

  final String filialId;

  final String urlImagem;

  final int largura;

  final int altura;

  final Vigencia vigencia;

  final DateTime criadoEm;

  final DateTime? excluidoEm;

  @override
  bool operator ==(Object other) =>
      other is PanfletoResponse &&
      other.id == id &&
      other.filialId == filialId &&
      other.urlImagem == urlImagem &&
      other.largura == largura &&
      other.altura == altura &&
      other.vigencia == vigencia &&
      other.criadoEm == criadoEm &&
      other.excluidoEm == excluidoEm;

  @override
  int get hashCode => Object.hash(
    id,
    filialId,
    urlImagem,
    largura,
    altura,
    vigencia,
    criadoEm,
    excluidoEm,
  );

  @override
  String toString() => 'PanfletoResponse(id: $id, $vigencia)';
}
