import 'package:flutter/foundation.dart';
import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/features/home/home_estado.dart';
import 'package:tabloide_core/src/features/home/services/home_service.dart';

/// Estado da home do painel, compartilhado entre app e web.
///
/// Conhece só o contrato [HomeService]; a implementação vem da plataforma.
class HomeController extends ChangeNotifier {
  /// Cria o controller com o service da plataforma.
  HomeController(this._service);

  final HomeService _service;

  SecaoPainel _secao = SecaoPainel.inicio;
  ResumoEstado _resumo = const ResumoCarregando();

  /// Seção exibida no momento.
  SecaoPainel get secao => _secao;

  /// Estado do resumo da seção Início.
  ResumoEstado get resumo => _resumo;

  /// Troca a seção exibida; não avisa ninguém se ela já estiver selecionada.
  void selecionar(SecaoPainel secao) {
    if (secao == _secao) return;
    _secao = secao;
    notifyListeners();
  }

  /// Busca o resumo; também serve para "tentar de novo".
  Future<void> carregarResumo() async {
    _resumo = const ResumoCarregando();
    notifyListeners();
    final resultado = await _service.buscarResumo();
    _resumo = switch (resultado) {
      Success(:final valor) => ResumoCarregado(valor),
      Failure(:final falha) => ResumoComFalha(falha),
    };
    notifyListeners();
  }
}
