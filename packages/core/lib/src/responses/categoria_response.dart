import 'package:tabloide_core/src/features/categorias/models/contagem_produtos.dart';

final class CategoriaResponse {
  const CategoriaResponse({
    required this.id,
    required this.nome,
    required this.produtos,
    required this.podeExcluir,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory CategoriaResponse.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'nome': final String nome,
      'produtos': final Object produtos,
      'podeExcluir': final bool podeExcluir,
      'criadoEm': final String criadoEm,
      'atualizadoEm': final String atualizadoEm,
    } =>
      CategoriaResponse(
        id: id,
        nome: nome,
        produtos: ContagemProdutos.fromJson(produtos),
        podeExcluir: podeExcluir,
        criadoEm: DateTime.parse(criadoEm),
        atualizadoEm: DateTime.parse(atualizadoEm),
      ),
    _ => throw const FormatException('Categoria fora do formato esperado'),
  };

  final String id;

  final String nome;

  final ContagemProdutos produtos;

  final bool podeExcluir;

  final DateTime criadoEm;

  final DateTime atualizadoEm;

  @override
  bool operator ==(Object other) =>
      other is CategoriaResponse &&
      other.id == id &&
      other.nome == nome &&
      other.produtos == produtos &&
      other.podeExcluir == podeExcluir &&
      other.criadoEm == criadoEm &&
      other.atualizadoEm == atualizadoEm;

  @override
  int get hashCode =>
      Object.hash(id, nome, produtos, podeExcluir, criadoEm, atualizadoEm);

  @override
  String toString() => 'CategoriaResponse($id, $nome, $produtos)';
}
