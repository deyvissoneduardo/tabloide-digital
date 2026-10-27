import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/home/paginas_publicadas_estado.dart';
import 'package:tabloide_app/src/features/home/services/paginas_publicadas_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Cards "Suas páginas" da home: contexto do lojista e QR Code por filial.
class PaginasPublicadasController extends ChangeNotifier {
  PaginasPublicadasController(this._service);

  final PaginasPublicadasServiceApp _service;

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

  /// Uma vez por filial (o PNG fica em memória; a falha também, para não
  /// repetir a chamada a cada redesenho).
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

  /// Regra §4.8 aplicada às contagens da filial.
  SituacaoPaginaFilial situacaoDe(ResumoFilial? resumo) {
    final sePanfleto = switch (_estado) {
      PaginasCarregadas(:final contexto) => contexto.sePanfleto,
      _ => false,
    };
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
