import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/produtos/produtos_estado.dart';
import 'package:tabloide_app/src/features/produtos/services/produto_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

typedef GrupoProdutos = ({
  CategoriaDoProduto categoria,
  List<ProdutoResponse> produtos,
});

int _alfabetica(String a, String b) =>
    a.toLowerCase().compareTo(b.toLowerCase());

class ProdutosController extends ChangeNotifier {
  ProdutosController(this._service);

  final ProdutoServiceApp _service;

  ProdutosEstado _estado = const ProdutosCarregando();
  String? _filialId;

  ProdutosEstado get estado => _estado;

  String? get filialId => _filialId;

  List<ProdutoResponse> get produtos => switch (_estado) {
    ProdutosCarregados(:final produtos) => produtos,
    _ => const [],
  };

  List<GrupoProdutos> get grupos {
    final porCategoria = <String, GrupoProdutos>{};
    for (final produto in produtos) {
      porCategoria
          .putIfAbsent(
            produto.categoria.id,
            () => (categoria: produto.categoria, produtos: []),
          )
          .produtos
          .add(produto);
    }
    return porCategoria.values.toList()
      ..sort((a, b) => _alfabetica(a.categoria.nome, b.categoria.nome));
  }

  Future<void> carregar(String filialId) async {
    _filialId = filialId;
    _estado = const ProdutosCarregando();
    notifyListeners();
    final resultado = await _service.listar(filialId);
    if (filialId != _filialId) return;
    switch (resultado) {
      case Success(:final valor):
        _atualizar(valor);
      case Failure(:final falha):
        _estado = ProdutosComFalha(falha);
    }
    notifyListeners();
  }

  void salvo(ProdutoResponse produto) {
    if (produto.filialId != _filialId) return;
    final existe = produtos.any((p) => p.id == produto.id);
    _atualizar([
      for (final p in produtos) p.id == produto.id ? produto : p,
      if (!existe) produto,
    ]);
    notifyListeners();
  }

  Future<Either<Falha, Nada>> excluir(ProdutoResponse produto) async {
    final resultado = await _service.excluir(produto.filialId, produto.id);
    if (resultado.isSuccess) {
      _atualizar([
        for (final p in produtos)
          if (p.id != produto.id) p,
      ]);
      notifyListeners();
    }
    return resultado;
  }

  void _atualizar(List<ProdutoResponse> produtos) {
    final ordenados = [...produtos]
      ..sort((a, b) => _alfabetica(a.nome, b.nome));
    _estado = ProdutosCarregados(List.unmodifiable(ordenados));
  }
}
