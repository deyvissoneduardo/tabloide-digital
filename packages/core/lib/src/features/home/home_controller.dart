import 'package:flutter/foundation.dart';
import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/features/home/home_estado.dart';
import 'package:tabloide_core/src/features/home/services/home_service.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._service);

  final HomeService _service;

  SecaoPainel _secao = SecaoPainel.inicio;
  ResumoEstado _resumo = const ResumoCarregando();
  List<String>? _filialIds;

  SecaoPainel get secao => _secao;

  ResumoEstado get resumo => _resumo;

  List<String>? get filialIds => _filialIds;

  void selecionar(SecaoPainel secao) {
    if (secao == _secao) return;
    _secao = secao;
    notifyListeners();
  }

  Future<void> carregarResumo(List<String> filialIds) async {
    final pedido = List<String>.unmodifiable(filialIds);
    _filialIds = pedido;
    _resumo = const ResumoCarregando();
    notifyListeners();
    final resultado = await _service.buscarResumo(pedido);
    if (!identical(pedido, _filialIds)) return;
    _resumo = switch (resultado) {
      Success(:final valor) => ResumoCarregado(valor),
      Failure(:final falha) => ResumoComFalha(falha),
    };
    notifyListeners();
  }
}
