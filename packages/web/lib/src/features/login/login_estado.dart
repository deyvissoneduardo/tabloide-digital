import 'package:tabloide_core/tabloide_core.dart';

/// Estado da tela de login.
sealed class LoginEstado {
  const LoginEstado();
}

/// Formulário esperando o lojista.
final class LoginOcioso extends LoginEstado {
  /// Cria o estado.
  const LoginOcioso();
}

/// Credenciais enviadas, aguardando a API.
final class LoginEnviando extends LoginEstado {
  /// Cria o estado.
  const LoginEnviando();
}

/// A API recusou ou não respondeu.
final class LoginComFalha extends LoginEstado {
  /// Cria o estado com a [falha].
  const LoginComFalha(this.falha);

  /// O que deu errado.
  final Falha falha;
}

/// Sessão aberta.
final class LoginConcluido extends LoginEstado {
  /// Cria o estado com a [sessao].
  const LoginConcluido(this.sessao);

  /// Token e lojista autenticado.
  final LoginResponse sessao;
}
