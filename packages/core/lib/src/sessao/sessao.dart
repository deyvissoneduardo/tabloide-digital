import 'package:tabloide_core/src/sessao/armazenamento_local.dart';

final class Sessao {
  Sessao(this._armazenamento, {DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  static const chaveToken = 'sessao.token';

  static const chaveExpiraEm = 'sessao.expiraEm';

  final ArmazenamentoLocal _armazenamento;

  final DateTime Function() _agora;

  String? _token;

  DateTime? _expiraEm;

  String? get token => switch (_expiraEm) {
    final expiraEm? when _agora().isBefore(expiraEm) => _token,
    _ => null,
  };

  bool get ativa => token != null;

  Future<bool> restaurar() async {
    if (ativa) return true;
    try {
      final token = await _armazenamento.ler(chaveToken);
      final expiraEm = DateTime.tryParse(
        await _armazenamento.ler(chaveExpiraEm) ?? '',
      );
      if (token == null || expiraEm == null) return false;
      _token = token;
      _expiraEm = expiraEm;
      if (ativa) return true;
      await encerrar();
      return false;
    } on Object {
      return false;
    }
  }

  Future<void> iniciar({
    required String token,
    required DateTime expiraEm,
  }) async {
    _token = token;
    _expiraEm = expiraEm;
    try {
      await _armazenamento.gravar(chaveToken, token);
      await _armazenamento.gravar(chaveExpiraEm, expiraEm.toIso8601String());
    } on Object {
      return;
    }
  }

  Future<void> encerrar() async {
    _token = null;
    _expiraEm = null;
    try {
      await _armazenamento.remover(chaveToken);
      await _armazenamento.remover(chaveExpiraEm);
    } on Object {
      return;
    }
  }
}
