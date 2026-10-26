import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/categorias/categorias_estado.dart';
import 'package:tabloide_app/src/features/categorias/services/categoria_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

class CategoriasController extends ChangeNotifier {
  CategoriasController(this._service);

  final CategoriaServiceApp _service;

  CategoriasEstado _estado = const CategoriasCarregando();
  String? _filialId;

  CategoriasEstado get estado => _estado;

  String? get filialId => _filialId;

  List<CategoriaResponse> get categorias => switch (_estado) {
    CategoriasCarregadas(:final categorias) => categorias,
    _ => const [],
  };

  Future<void> carregar(String filialId) async {
    _filialId = filialId;
    _estado = const CategoriasCarregando();
    notifyListeners();
    final resultado = await _service.listar(filialId);
    if (filialId != _filialId) return;
    switch (resultado) {
      case Success(:final valor):
        _atualizar(valor);
      case Failure(:final falha):
        _estado = CategoriasComFalha(falha);
    }
    notifyListeners();
  }

  void salva(CategoriaResponse categoria) {
    final existe = categorias.any((c) => c.id == categoria.id);
    _atualizar([
      for (final c in categorias) c.id == categoria.id ? categoria : c,
      if (!existe) categoria,
    ]);
    notifyListeners();
  }

  Future<Either<Falha, Nada>> excluir(CategoriaResponse categoria) async {
    final filialId = _filialId;
    if (filialId == null) return const Success(Nada());
    final resultado = await _service.excluir(filialId, categoria.id);
    if (resultado.isSuccess) {
      _atualizar([
        for (final c in categorias)
          if (c.id != categoria.id) c,
      ]);
      notifyListeners();
    }
    return resultado;
  }

  void _atualizar(List<CategoriaResponse> categorias) {
    final ordenadas = [...categorias]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    _estado = CategoriasCarregadas(List.unmodifiable(ordenadas));
  }
}
