import 'package:flutter/foundation.dart';
import 'package:tabloide_core/src/features/vigencia/models/vigencia.dart';

/// Ordem da página de uma filial (plano §4.2): todas as categorias e, em cada
/// uma, os produtos vigentes e agendados, já na ordem de exibição.
final class EstruturaResponse {
  const EstruturaResponse({required this.categorias});

  factory EstruturaResponse.fromJson(Object? json) => switch (json) {
    {'categorias': final List<dynamic> categorias} => EstruturaResponse(
      categorias: [
        for (final categoria in categorias)
          CategoriaEstruturaResponse.fromJson(categoria),
      ],
    ),
    _ => throw const FormatException('Estrutura fora do formato esperado'),
  };

  final List<CategoriaEstruturaResponse> categorias;

  @override
  bool operator ==(Object other) =>
      other is EstruturaResponse && listEquals(other.categorias, categorias);

  @override
  int get hashCode => Object.hashAll(categorias);

  @override
  String toString() => 'EstruturaResponse($categorias)';
}

final class CategoriaEstruturaResponse {
  const CategoriaEstruturaResponse({
    required this.id,
    required this.nome,
    required this.produtos,
  });

  factory CategoriaEstruturaResponse.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'nome': final String nome,
      'produtos': final List<dynamic> produtos,
    } =>
      CategoriaEstruturaResponse(
        id: id,
        nome: nome,
        produtos: [
          for (final produto in produtos)
            ProdutoEstruturaResponse.fromJson(produto),
        ],
      ),
    _ => throw const FormatException(
      'Categoria da estrutura fora do formato esperado',
    ),
  };

  final String id;

  final String nome;

  final List<ProdutoEstruturaResponse> produtos;

  CategoriaEstruturaResponse comProdutos(
    List<ProdutoEstruturaResponse> produtos,
  ) => CategoriaEstruturaResponse(id: id, nome: nome, produtos: produtos);

  @override
  bool operator ==(Object other) =>
      other is CategoriaEstruturaResponse &&
      other.id == id &&
      other.nome == nome &&
      listEquals(other.produtos, produtos);

  @override
  int get hashCode => Object.hash(id, nome, Object.hashAll(produtos));

  @override
  String toString() => 'CategoriaEstruturaResponse($id, $nome, $produtos)';
}

final class ProdutoEstruturaResponse {
  const ProdutoEstruturaResponse({
    required this.id,
    required this.nome,
    required this.precoPromocionalCentavos,
    required this.vigencia,
    this.quantidade,
    this.descricao,
    this.observacao,
    this.precoOriginalCentavos,
    this.urlFoto,
  });

  factory ProdutoEstruturaResponse.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'nome': final String nome,
      'quantidade': final String? quantidade,
      'descricao': final String? descricao,
      'observacao': final String? observacao,
      'precoPromocionalCentavos': final int precoPromocionalCentavos,
      'precoOriginalCentavos': final int? precoOriginalCentavos,
      'urlFoto': final String? urlFoto,
    } =>
      ProdutoEstruturaResponse(
        id: id,
        nome: nome,
        quantidade: quantidade,
        descricao: descricao,
        observacao: observacao,
        precoPromocionalCentavos: precoPromocionalCentavos,
        precoOriginalCentavos: precoOriginalCentavos,
        urlFoto: urlFoto,
        vigencia: Vigencia.fromJson(json),
      ),
    _ => throw const FormatException(
      'Produto da estrutura fora do formato esperado',
    ),
  };

  final String id;

  final String nome;

  final String? quantidade;

  final String? descricao;

  final String? observacao;

  final int precoPromocionalCentavos;

  final int? precoOriginalCentavos;

  final String? urlFoto;

  final Vigencia vigencia;

  @override
  bool operator ==(Object other) =>
      other is ProdutoEstruturaResponse &&
      other.id == id &&
      other.nome == nome &&
      other.quantidade == quantidade &&
      other.descricao == descricao &&
      other.observacao == observacao &&
      other.precoPromocionalCentavos == precoPromocionalCentavos &&
      other.precoOriginalCentavos == precoOriginalCentavos &&
      other.urlFoto == urlFoto &&
      other.vigencia == vigencia;

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    quantidade,
    descricao,
    observacao,
    precoPromocionalCentavos,
    precoOriginalCentavos,
    urlFoto,
    vigencia,
  );

  @override
  String toString() => 'ProdutoEstruturaResponse($id, $nome, $vigencia)';
}
