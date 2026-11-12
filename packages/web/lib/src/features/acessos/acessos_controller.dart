import 'package:flutter/foundation.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/acessos/acessos_estado.dart';
import 'package:tabloide_web/src/features/acessos/services/acessos_service_web.dart';

class AcessosController extends ChangeNotifier {
  AcessosController(this._service);

  final AcessosServiceWeb _service;

  PeriodoAcessos _periodo = PeriodoAcessos.padrao;
  String? _filialId;
  List<String> _filiais = const [];
  ResumoAcessosEstado _resumo = const ResumoAcessosCarregando();
  PanfletosAcessosEstado _panfletos = const PanfletosAcessosOcioso();
  bool _recarregando = false;
  Object? _pedido;

  PeriodoAcessos get periodo => _periodo;

  String? get filialId => _filialId;

  ResumoAcessosEstado get resumo => _resumo;

  PanfletosAcessosEstado get panfletos => _panfletos;

  bool get recarregando => _recarregando;

  String? get filialDosPanfletos =>
      _filialId ?? (_filiais.length == 1 ? _filiais.single : null);

  Future<void> carregar() async {
    final pedido = Object();
    _pedido = pedido;
    final periodo = _periodo;
    final filialPanfletos = filialDosPanfletos;
    _recarregando = _resumo is ResumoAcessosCarregado;
    if (!_recarregando) _resumo = const ResumoAcessosCarregando();
    _panfletos = filialPanfletos == null
        ? const PanfletosAcessosOcioso()
        : const PanfletosAcessosCarregando();
    notifyListeners();
    final (resumo, panfletos) = await (
      _service.resumo(periodo, filialId: _filialId),
      filialPanfletos == null
          ? Future<Either<Falha, AcessosPanfletosResponse>?>.value()
          : _service.panfletos(filialPanfletos, periodo),
    ).wait;
    if (!identical(pedido, _pedido)) return;
    _recarregando = false;
    _resumo = switch (resumo) {
      Success(:final valor) => ResumoAcessosCarregado(valor, periodo),
      Failure(:final falha) => ResumoAcessosComFalha(falha),
    };
    _panfletos = switch (panfletos) {
      null => const PanfletosAcessosOcioso(),
      Success(:final valor) => PanfletosAcessosCarregados(valor.itens),
      Failure(:final falha) => PanfletosAcessosComFalha(falha),
    };
    notifyListeners();
  }

  Future<void> mudarPeriodo(PeriodoAcessos periodo) async {
    if (periodo == _periodo) return;
    _periodo = periodo;
    await carregar();
  }

  Future<void> mudarFilial(String? filialId) async {
    if (filialId == _filialId) return;
    _filialId = filialId;
    await carregar();
  }

  Future<void> filiaisMudaram(List<String> filialIds) async {
    _filiais = List.unmodifiable(filialIds);
    if (_filialId case final id? when !filialIds.contains(id)) {
      _filialId = null;
    }
    await carregar();
  }
}
