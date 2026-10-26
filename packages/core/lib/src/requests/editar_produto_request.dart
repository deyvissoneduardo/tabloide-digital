import 'package:tabloide_core/src/requests/produto_request.dart';
import 'package:tabloide_core/src/responses/produto_response.dart';

const _semNulo = {'nome', 'categoriaId', 'precoPromocionalCentavos'};

final class EditarProdutoRequest {
  const EditarProdutoRequest._(this._campos);

  factory EditarProdutoRequest.entre(
    ProdutoResponse atual,
    ProdutoRequest novo,
  ) {
    final vigencia = atual.vigencia;
    final antes = ProdutoRequest(
      nome: atual.nome,
      categoriaId: atual.categoria.id,
      precoPromocionalCentavos: atual.precoPromocionalCentavos,
      precoOriginalCentavos: atual.precoOriginalCentavos,
      quantidade: atual.quantidade,
      descricao: atual.descricao,
      observacao: atual.observacao,
      dataInicio: vigencia.dataInicio,
      dataLimite: vigencia.dataLimite,
    ).toJson();
    final depois = novo.toJson();
    if (!vigencia.podeAlterarInicio || novo.dataInicio == null) {
      depois.remove('dataInicio');
      antes.remove('dataInicio');
    }
    return EditarProdutoRequest._({
      for (final MapEntry(:key, :value) in depois.entries)
        if (antes[key] != value) key: value,
      for (final chave in antes.keys)
        if (!depois.containsKey(chave) && !_semNulo.contains(chave))
          chave: null,
    });
  }

  final Map<String, Object?> _campos;

  bool get vazio => _campos.isEmpty;

  Map<String, Object?> toJson() => {..._campos};

  @override
  bool operator ==(Object other) =>
      other is EditarProdutoRequest &&
      other._campos.length == _campos.length &&
      _campos.entries.every(
        (e) =>
            other._campos.containsKey(e.key) && other._campos[e.key] == e.value,
      );

  @override
  int get hashCode => Object.hashAllUnordered([
    for (final MapEntry(:key, :value) in _campos.entries)
      Object.hash(key, value),
  ]);

  @override
  String toString() => 'EditarProdutoRequest($_campos)';
}
