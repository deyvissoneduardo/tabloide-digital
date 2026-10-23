import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/login/login_estado.dart';
import 'package:tabloide_app/src/features/login/services/auth_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Estado do login no app; a sessão aberta fica só em memória.
class LoginController extends ChangeNotifier {
  /// Cria o controller com o service do app.
  LoginController(this._service);

  final AuthServiceApp _service;

  LoginEstado _estado = const LoginOcioso();

  /// Estado atual do login.
  LoginEstado get estado => _estado;

  /// Sessão aberta, ou `null` antes do login.
  LoginResponse? get sessao => switch (_estado) {
    LoginConcluido(:final sessao) => sessao,
    _ => null,
  };

  /// Envia as credenciais; ignora o pedido se já houver um em andamento.
  Future<void> entrar({required String email, required String senha}) async {
    if (_estado is LoginEnviando) return;
    _estado = const LoginEnviando();
    notifyListeners();
    final resultado = await _service.entrar(
      LoginRequest(email: email.trim(), senha: senha),
    );
    _estado = switch (resultado) {
      Success(:final valor) => LoginConcluido(valor),
      Failure(:final falha) => LoginComFalha(falha),
    };
    notifyListeners();
  }
}
