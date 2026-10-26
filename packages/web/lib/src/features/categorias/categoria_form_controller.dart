import 'package:flutter/foundation.dart';
import 'package:tabloide_web/src/features/categorias/categoria_form_estado.dart';
import 'package:tabloide_web/src/features/categorias/services/categoria_service_web.dart';
import 'package:tabloide_core/tabloide_core.dart';

class CategoriaFormController extends ChangeNotifier {
  CategoriaFormController(this._service);

  final CategoriaServiceWeb _service;

  CategoriaFormEstado _estado = const CategoriaFormOcioso();
  String? _erroNome;

  CategoriaFormEstado get estado => _estado;

  String? get erroNome => _erroNome;

  void reiniciar() {
    _estado = const CategoriaFormOcioso();
    _erroNome = null;
  }

  void limparErroNome() {
    if (_erroNome == null) return;
    _erroNome = null;
    notifyListeners();
  }

  Future<void> salvar({
    required String filialId,
    required String nome,
    CategoriaResponse? categoria,
  }) async {
    if (_estado is CategoriaFormEnviando) return;
    _estado = const CategoriaFormEnviando();
    _erroNome = null;
    notifyListeners();
    final request = CategoriaRequest(nome: nome);
    final resultado = switch (categoria) {
      final categoria? => await _service.renomear(
        filialId,
        categoria.id,
        request,
      ),
      null => await _service.criar(filialId, request),
    };
    switch (resultado) {
      case Success(:final valor):
        _estado = CategoriaFormConcluido(valor);
      case Failure(:final falha):
        _estado = CategoriaFormComFalha(falha);
        _erroNome = switch (falha) {
          FalhaApi(codigo: 'CATEGORIA_JA_EXISTE', :final mensagem) => mensagem,
          FalhaApi(:final campos) => campos['nome']?.toSet().join('\n'),
          _ => null,
        };
    }
    notifyListeners();
  }
}
