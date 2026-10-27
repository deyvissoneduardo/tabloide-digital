import 'package:flutter/foundation.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';

final class CategoriaOrdenada {
  const CategoriaOrdenada({required this.id, required this.produtos});

  final String id;

  final List<String> produtos;

  Map<String, Object?> toJson() => {'id': id, 'produtos': produtos};

  @override
  bool operator ==(Object other) =>
      other is CategoriaOrdenada &&
      other.id == id &&
      listEquals(other.produtos, produtos);

  @override
  int get hashCode => Object.hash(id, Object.hashAll(produtos));

  @override
  String toString() => 'CategoriaOrdenada($id, $produtos)';
}

/// Corpo do `PUT /painel/filiais/:id/estrutura` (plano §4.2).
final class EstruturaRequest {
  const EstruturaRequest(this.categorias);

  /// Monta a partir da ordem em edição: categorias e produtos na ordem exibida.
  factory EstruturaRequest.daEstrutura(
    List<CategoriaEstruturaResponse> categorias,
  ) => EstruturaRequest([
    for (final categoria in categorias)
      CategoriaOrdenada(
        id: categoria.id,
        produtos: [for (final produto in categoria.produtos) produto.id],
      ),
  ]);

  final List<CategoriaOrdenada> categorias;

  Map<String, Object?> toJson() => {
    'categorias': [for (final categoria in categorias) categoria.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is EstruturaRequest && listEquals(other.categorias, categorias);

  @override
  int get hashCode => Object.hashAll(categorias);

  @override
  String toString() => 'EstruturaRequest($categorias)';
}
