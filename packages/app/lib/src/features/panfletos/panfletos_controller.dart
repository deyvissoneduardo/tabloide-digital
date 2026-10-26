import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/panfletos/panfletos_estado.dart';
import 'package:tabloide_app/src/features/panfletos/services/panfleto_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

class PanfletosController extends ChangeNotifier {
  PanfletosController(this._service);

  final PanfletoServiceApp _service;

  PanfletosEstado _estado = const PanfletosCarregando();
  String? _filialId;

  PanfletosEstado get estado => _estado;

  String? get filialId => _filialId;

  List<PanfletoResponse> get panfletos => switch (_estado) {
    PanfletosCarregados(:final panfletos) => panfletos,
    _ => const [],
  };

  bool get atualSemDataLimite => panfletos.any(
    (p) =>
        p.vigencia.situacao == SituacaoVigencia.vigente &&
        p.vigencia.dataLimite == null,
  );

  Future<void> carregar(String filialId) async {
    _filialId = filialId;
    _estado = const PanfletosCarregando();
    notifyListeners();
    final resultado = await _service.listar(filialId);
    if (filialId != _filialId) return;
    switch (resultado) {
      case Success(:final valor):
        _atualizar(valor);
      case Failure(:final falha):
        _estado = PanfletosComFalha(falha);
    }
    notifyListeners();
  }

  void salvo(PanfletoResponse panfleto) {
    if (panfleto.filialId != _filialId) return;
    final existe = panfletos.any((p) => p.id == panfleto.id);
    _atualizar([
      for (final p in panfletos) p.id == panfleto.id ? panfleto : p,
      if (!existe) panfleto,
    ]);
    notifyListeners();
  }

  Future<Either<Falha, Nada>> excluir(PanfletoResponse panfleto) async {
    final resultado = await _service.excluir(panfleto.filialId, panfleto.id);
    if (resultado.isSuccess) {
      _atualizar([
        for (final p in panfletos)
          if (p.id != panfleto.id) p,
      ]);
      notifyListeners();
    }
    return resultado;
  }

  void _atualizar(List<PanfletoResponse> panfletos) {
    final ordenados = [...panfletos]
      ..sort((a, b) => a.vigencia.dataInicio.compareTo(b.vigencia.dataInicio));
    _estado = PanfletosCarregados(List.unmodifiable(ordenados));
  }
}
