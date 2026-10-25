import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/cadastro/cadastro_estado.dart';
import 'package:tabloide_app/src/features/cadastro/services/cadastro_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

final _mascara = RegExp('[^0-9a-zA-Z]');

class CadastroController extends ChangeNotifier {
  CadastroController(this._service);

  final CadastroServiceApp _service;

  CadastroEstado _estado = const CadastroOcioso();
  Map<String, List<String>> _errosDosCampos = const {};

  CadastroEstado get estado => _estado;

  CadastroResponse? get conta => switch (_estado) {
    CadastroConcluido(:final conta) => conta,
    _ => null,
  };

  void reiniciar() {
    _estado = const CadastroOcioso();
    _errosDosCampos = const {};
  }

  String? erroDoCampo(String campo) =>
      _errosDosCampos[campo]?.toSet().join('\n');

  void limparErroDoCampo(String campo) {
    if (!_errosDosCampos.containsKey(campo)) return;
    _errosDosCampos = {..._errosDosCampos}..remove(campo);
    notifyListeners();
  }

  Future<void> cadastrar({
    required String nomeFantasia,
    required String nomeResponsavel,
    required String email,
    required String senha,
    required String whatsapp,
    required String cnpj,
  }) async {
    if (_estado is CadastroEnviando) return;
    _estado = const CadastroEnviando();
    _errosDosCampos = const {};
    notifyListeners();
    final resultado = await _service.cadastrar(
      CadastroRequest(
        nomeFantasia: nomeFantasia.trim(),
        nomeResponsavel: nomeResponsavel.trim(),
        email: email.trim(),
        senha: senha.trim(),
        whatsapp: whatsapp.replaceAll(_mascara, ''),
        cnpj: cnpj.replaceAll(_mascara, ''),
      ),
    );
    switch (resultado) {
      case Success(:final valor):
        _estado = CadastroConcluido(valor);
      case Failure(:final falha):
        _estado = CadastroComFalha(falha);
        if (falha case FalhaApi(:final campos)) _errosDosCampos = campos;
    }
    notifyListeners();
  }
}
