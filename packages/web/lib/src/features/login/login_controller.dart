import 'package:flutter/foundation.dart';
import 'package:tabloide_web/src/features/login/login_estado.dart';
import 'package:tabloide_web/src/features/login/services/auth_service_web.dart';
import 'package:tabloide_core/tabloide_core.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._service);

  final AuthServiceWeb _service;

  LoginEstado _estado = const LoginOcioso();

  LoginEstado get estado => _estado;

  LoginResponse? get sessao => switch (_estado) {
    LoginConcluido(:final sessao) => sessao,
    _ => null,
  };

  Future<void> entrar({required String email, required String senha}) async {
    if (_estado is LoginEnviando) return;
    _estado = const LoginEnviando();
    notifyListeners();
    final resultado = await _service.entrar(
      LoginRequest(email: email.trim(), senha: senha.trim()),
    );
    _estado = switch (resultado) {
      Success(:final valor) => LoginConcluido(valor),
      Failure(:final falha) => LoginComFalha(falha),
    };
    notifyListeners();
  }

  Future<void> sair() async {
    await _service.sair();
    _estado = const LoginOcioso();
    notifyListeners();
  }
}
