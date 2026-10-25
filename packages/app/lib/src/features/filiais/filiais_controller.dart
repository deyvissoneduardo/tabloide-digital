import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/filiais/filiais_estado.dart';
import 'package:tabloide_app/src/features/filiais/services/filial_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

class FiliaisController extends ChangeNotifier {
  FiliaisController(this._service);

  final FilialServiceApp _service;

  FiliaisEstado _estado = const FiliaisCarregando();
  FilialResponse? _emUso;

  FiliaisEstado get estado => _estado;

  FilialResponse? get emUso => _emUso;

  List<FilialResponse> get filiais => switch (_estado) {
    FiliaisCarregadas(:final filiais) => filiais,
    _ => const [],
  };

  bool get podeExcluir => filiais.length > 1;

  Future<void> carregar() async {
    _estado = const FiliaisCarregando();
    notifyListeners();
    final resultado = await _service.listar();
    switch (resultado) {
      case Success(:final valor):
        _atualizar(valor);
      case Failure(:final falha):
        _estado = FiliaisComFalha(falha);
    }
    notifyListeners();
  }

  void limpar() {
    _estado = const FiliaisCarregando();
    _emUso = null;
    notifyListeners();
  }

  void usar(FilialResponse filial) {
    _emUso = filial;
    notifyListeners();
  }

  void salva(FilialResponse filial) {
    final existe = filiais.any((f) => f.id == filial.id);
    _atualizar([
      for (final f in filiais) f.id == filial.id ? filial : f,
      if (!existe) filial,
    ]);
    notifyListeners();
  }

  Future<Either<Falha, Nada>> excluir(FilialResponse filial) async {
    final resultado = await _service.excluir(filial.id);
    if (resultado.isSuccess) {
      _atualizar([
        for (final f in filiais)
          if (f.id != filial.id) f,
      ]);
      notifyListeners();
    }
    return resultado;
  }

  void _atualizar(List<FilialResponse> filiais) {
    _estado = FiliaisCarregadas(List.unmodifiable(filiais));
    final atual = filiais.where((f) => f.id == _emUso?.id).firstOrNull;
    _emUso = atual ?? (filiais.length == 1 ? filiais.single : null);
  }
}
