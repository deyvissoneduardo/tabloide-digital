import 'package:flutter/foundation.dart';
import 'package:tabloide_web/src/features/home/paginas_publicadas_estado.dart';
import 'package:tabloide_web/src/features/home/services/paginas_publicadas_service_web.dart';
import 'package:tabloide_core/tabloide_core.dart';

class PaginasPublicadasController extends ChangeNotifier {
  PaginasPublicadasController(this._service);

  final PaginasPublicadasServiceWeb _service;

  PaginasPublicadasEstado _estado = const PaginasCarregando();
  final _qrCodes = <String, Uint8List?>{};
  final _qrCodesComFalha = <String>{};

  PaginasPublicadasEstado get estado => _estado;

  Map<String, Uint8List?> get qrCodes => Map.unmodifiable(_qrCodes);

  Set<String> get qrCodesComFalha => Set.unmodifiable(_qrCodesComFalha);

  Future<void> carregar() async {
    _estado = const PaginasCarregando();
    notifyListeners();
    final resultado = await _service.carregar();
    _estado = switch (resultado) {
      Success(:final valor) => PaginasCarregadas(valor),
      Failure(:final falha) => PaginasComFalha(falha),
    };
    notifyListeners();
  }

  Future<void> carregarQrCode(String filialId) async {
    if (_qrCodes.containsKey(filialId) || _qrCodesComFalha.contains(filialId)) {
      return;
    }
    _qrCodes[filialId] = null;
    final resultado = await _service.qrCode(filialId);
    switch (resultado) {
      case Success(:final valor):
        _qrCodes[filialId] = valor;
      case Failure():
        _qrCodes.remove(filialId);
        _qrCodesComFalha.add(filialId);
    }
    notifyListeners();
  }

  SituacaoPaginaFilial situacaoDe(
    ResumoFilial? resumo, {
    required bool sePanfleto,
  }) {
    return switch (resumo) {
      ResumoFilial(:final panfletosVigentes)
          when sePanfleto && panfletosVigentes > 0 =>
        SituacaoPaginaFilial.panfleto,
      ResumoFilial(:final produtosVigentes) when produtosVigentes > 0 =>
        SituacaoPaginaFilial.produtos,
      _ => SituacaoPaginaFilial.vazia,
    };
  }
}
