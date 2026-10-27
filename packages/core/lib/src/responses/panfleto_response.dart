import 'package:tabloide_core/src/features/panfletos/models/tipo_arquivo_panfleto.dart';
import 'package:tabloide_core/src/features/vigencia/models/vigencia.dart';

final class PanfletoResponse {
  const PanfletoResponse({
    required this.id,
    required this.filialId,
    required this.tipo,
    required this.urlArquivo,
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
      'tipo': final String codigoTipo,
      'urlArquivo': final String urlArquivo,
      'largura': final int largura,
      'altura': final int altura,
      'criadoEm': final String criadoEm,
      'excluidoEm': final String? excluidoEm,
    } =>
      PanfletoResponse(
        id: id,
        filialId: filialId,
        tipo: switch (TipoArquivoPanfleto.doCodigo(codigoTipo)) {
          final tipo? => tipo,
          null => throw FormatException(
            'Tipo de panfleto desconhecido',
            codigoTipo,
          ),
        },
        urlArquivo: urlArquivo,
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

  final TipoArquivoPanfleto tipo;

  /// Imagem ou PDF original (a API ainda manda `urlImagem` com o mesmo valor,
  /// só para apps antigos; o painel ignora).
  final String urlArquivo;

  /// Último segmento de [urlArquivo] (ex.: `0192f0c0.pdf`).
  String get nomeArquivo {
    final caminho = Uri.tryParse(urlArquivo)?.pathSegments ?? const [];
    return caminho.isEmpty ? urlArquivo : caminho.last;
  }

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
      other.tipo == tipo &&
      other.urlArquivo == urlArquivo &&
      other.largura == largura &&
      other.altura == altura &&
      other.vigencia == vigencia &&
      other.criadoEm == criadoEm &&
      other.excluidoEm == excluidoEm;

  @override
  int get hashCode => Object.hash(
    id,
    filialId,
    tipo,
    urlArquivo,
    largura,
    altura,
    vigencia,
    criadoEm,
    excluidoEm,
  );

  @override
  String toString() => 'PanfletoResponse(id: $id, $vigencia)';
}
