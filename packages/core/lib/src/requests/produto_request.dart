import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';

String? _texto(String? texto) => switch (texto?.trim()) {
  final t? when t.isNotEmpty => t,
  _ => null,
};

final class ProdutoRequest {
  const ProdutoRequest({
    required this.nome,
    required this.categoriaId,
    required this.precoPromocionalCentavos,
    this.precoOriginalCentavos,
    this.quantidade,
    this.descricao,
    this.observacao,
    this.dataInicio,
    this.dataLimite,
  });

  final String nome;

  final String categoriaId;

  final int precoPromocionalCentavos;

  final int? precoOriginalCentavos;

  final String? quantidade;

  final String? descricao;

  final String? observacao;

  final DateTime? dataInicio;

  final DateTime? dataLimite;

  Map<String, Object> toJson() => {
    'nome': nome.trim(),
    'categoriaId': categoriaId,
    'precoPromocionalCentavos': precoPromocionalCentavos,
    'precoOriginalCentavos': ?precoOriginalCentavos,
    'quantidade': ?_texto(quantidade),
    'descricao': ?_texto(descricao),
    'observacao': ?_texto(observacao),
    if (dataInicio case final inicio?) 'dataInicio': DataDia.iso(inicio),
    if (dataLimite case final limite?) 'dataLimite': DataDia.iso(limite),
  };

  Map<String, String> toCampos() => {
    for (final MapEntry(:key, :value) in toJson().entries) key: '$value',
  };

  @override
  bool operator ==(Object other) =>
      other is ProdutoRequest &&
      other.nome == nome &&
      other.categoriaId == categoriaId &&
      other.precoPromocionalCentavos == precoPromocionalCentavos &&
      other.precoOriginalCentavos == precoOriginalCentavos &&
      other.quantidade == quantidade &&
      other.descricao == descricao &&
      other.observacao == observacao &&
      other.dataInicio == dataInicio &&
      other.dataLimite == dataLimite;

  @override
  int get hashCode => Object.hash(
    nome,
    categoriaId,
    precoPromocionalCentavos,
    precoOriginalCentavos,
    quantidade,
    descricao,
    observacao,
    dataInicio,
    dataLimite,
  );

  @override
  String toString() => 'ProdutoRequest($nome, categoria: $categoriaId)';
}
