import 'package:tabloide_core/src/features/produtos/models/categoria_do_produto.dart';
import 'package:tabloide_core/src/features/vigencia/models/vigencia.dart';

final class ProdutoResponse {
  const ProdutoResponse({
    required this.id,
    required this.filialId,
    required this.categoria,
    required this.nome,
    required this.precoPromocionalCentavos,
    required this.vigencia,
    required this.criadoEm,
    required this.atualizadoEm,
    this.quantidade,
    this.precoOriginalCentavos,
    this.descricao,
    this.observacao,
    this.urlFoto,
    this.excluidoEm,
  });

  factory ProdutoResponse.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'filialId': final String filialId,
      'categoria': final Object categoria,
      'nome': final String nome,
      'quantidade': final String? quantidade,
      'precoPromocionalCentavos': final int precoPromocionalCentavos,
      'precoOriginalCentavos': final int? precoOriginalCentavos,
      'descricao': final String? descricao,
      'observacao': final String? observacao,
      'urlFoto': final String? urlFoto,
      'criadoEm': final String criadoEm,
      'atualizadoEm': final String atualizadoEm,
      'excluidoEm': final String? excluidoEm,
    } =>
      ProdutoResponse(
        id: id,
        filialId: filialId,
        categoria: CategoriaDoProduto.fromJson(categoria),
        nome: nome,
        quantidade: quantidade,
        precoPromocionalCentavos: precoPromocionalCentavos,
        precoOriginalCentavos: precoOriginalCentavos,
        descricao: descricao,
        observacao: observacao,
        urlFoto: urlFoto,
        vigencia: Vigencia.fromJson(json),
        criadoEm: DateTime.parse(criadoEm),
        atualizadoEm: DateTime.parse(atualizadoEm),
        excluidoEm: excluidoEm == null ? null : DateTime.parse(excluidoEm),
      ),
    _ => throw const FormatException('Produto fora do formato esperado'),
  };

  final String id;

  final String filialId;

  final CategoriaDoProduto categoria;

  final String nome;

  final String? quantidade;

  final int precoPromocionalCentavos;

  final int? precoOriginalCentavos;

  final String? descricao;

  final String? observacao;

  final String? urlFoto;

  final Vigencia vigencia;

  final DateTime criadoEm;

  final DateTime atualizadoEm;

  final DateTime? excluidoEm;

  @override
  bool operator ==(Object other) =>
      other is ProdutoResponse &&
      other.id == id &&
      other.filialId == filialId &&
      other.categoria == categoria &&
      other.nome == nome &&
      other.quantidade == quantidade &&
      other.precoPromocionalCentavos == precoPromocionalCentavos &&
      other.precoOriginalCentavos == precoOriginalCentavos &&
      other.descricao == descricao &&
      other.observacao == observacao &&
      other.urlFoto == urlFoto &&
      other.vigencia == vigencia &&
      other.criadoEm == criadoEm &&
      other.atualizadoEm == atualizadoEm &&
      other.excluidoEm == excluidoEm;

  @override
  int get hashCode => Object.hash(
    id,
    filialId,
    categoria,
    nome,
    quantidade,
    precoPromocionalCentavos,
    precoOriginalCentavos,
    descricao,
    observacao,
    urlFoto,
    vigencia,
    criadoEm,
    atualizadoEm,
    excluidoEm,
  );

  @override
  String toString() => 'ProdutoResponse($id, $nome, $vigencia)';
}
