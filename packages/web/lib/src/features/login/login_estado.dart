import 'package:tabloide_core/tabloide_core.dart';

sealed class LoginEstado {
  const LoginEstado();
}

final class LoginOcioso extends LoginEstado {
  const LoginOcioso();
}

final class LoginEnviando extends LoginEstado {
  const LoginEnviando();
}

final class LoginComFalha extends LoginEstado {
  const LoginComFalha(this.falha);

  final Falha falha;
}

final class LoginConcluido extends LoginEstado {
  const LoginConcluido(this.sessao);

  final LoginResponse sessao;
}
