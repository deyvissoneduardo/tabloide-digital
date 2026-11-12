import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';

enum SituacaoAcessoPanfleto {
  vigente('VIGENTE', 'Vigente'),

  vencido('VENCIDO', 'Encerrado'),

  excluido('EXCLUIDO', 'Excluído');

  const SituacaoAcessoPanfleto(this.codigo, this.rotulo);

  final String codigo;

  final String rotulo;

  static SituacaoAcessoPanfleto? doCodigo(String codigo) {
    for (final situacao in values) {
      if (situacao.codigo == codigo) return situacao;
    }
    return null;
  }
}

final class AcessosPanfletosResponse {
  const AcessosPanfletosResponse(this.itens);

  factory AcessosPanfletosResponse.fromJson(Object? json) => switch (json) {
    {'itens': final List<dynamic> itens} => AcessosPanfletosResponse(
      List.unmodifiable(itens.map(AcessosPanfletoResponse.fromJson)),
    ),
    _ => throw const FormatException('Acessos por panfleto fora do formato'),
  };

  final List<AcessosPanfletoResponse> itens;
}

final class AcessosPanfletoResponse {
  const AcessosPanfletoResponse({
    required this.panfletoId,
    required this.dataInicio,
    required this.dataFimContagem,
    required this.situacao,
    required this.totalAcessos,
    required this.dias,
    required this.mediaPorDia,
    this.dataLimite,
  });

  factory AcessosPanfletoResponse.fromJson(Object? json) => switch (json) {
    {
      'panfletoId': final String panfletoId,
      'dataInicio': final String dataInicio,
      'dataLimite': final String? dataLimite,
      'dataFimContagem': final String dataFimContagem,
      'situacao': final String situacao,
      'totalAcessos': final int totalAcessos,
      'dias': final int dias,
      'mediaPorDia': final num mediaPorDia,
    } =>
      AcessosPanfletoResponse(
        panfletoId: panfletoId,
        dataInicio: DataDia.ler(dataInicio),
        dataLimite: dataLimite == null ? null : DataDia.ler(dataLimite),
        dataFimContagem: DataDia.ler(dataFimContagem),
        situacao: switch (SituacaoAcessoPanfleto.doCodigo(situacao)) {
          final valor? => valor,
          null => throw FormatException('Situação desconhecida', situacao),
        },
        totalAcessos: totalAcessos,
        dias: dias,
        mediaPorDia: mediaPorDia.toDouble(),
      ),
    _ => throw const FormatException('Acessos do panfleto fora do formato'),
  };

  final String panfletoId;

  final DateTime dataInicio;

  final DateTime? dataLimite;

  final DateTime dataFimContagem;

  final SituacaoAcessoPanfleto situacao;

  final int totalAcessos;

  final int dias;

  final double mediaPorDia;
}
