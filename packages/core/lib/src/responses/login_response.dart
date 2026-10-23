import 'package:tabloide_core/src/responses/lojista_response.dart';

/// Sessão aberta por `POST /auth/login`.
final class LoginResponse {
  /// Cria a sessão.
  const LoginResponse({
    required this.lojista,
    required this.token,
    required this.expiraEm,
  });

  /// Lê o JSON da API; lança [FormatException] se faltar campo.
  factory LoginResponse.fromJson(Object? json) => switch (json) {
    {
      'lojista': final Object lojista,
      'token': final String token,
      'expiraEm': final String expiraEm,
    } =>
      LoginResponse(
        lojista: LojistaResponse.fromJson(lojista),
        token: token,
        expiraEm: DateTime.parse(expiraEm),
      ),
    _ => throw const FormatException('Login fora do formato esperado'),
  };

  /// Lojista autenticado.
  final LojistaResponse lojista;

  /// JWT para as próximas chamadas.
  final String token;

  /// Quando o [token] deixa de valer.
  final DateTime expiraEm;

  @override
  bool operator ==(Object other) =>
      other is LoginResponse &&
      other.lojista == lojista &&
      other.token == token &&
      other.expiraEm == expiraEm;

  @override
  int get hashCode => Object.hash(lojista, token, expiraEm);

  // O token fica fora do texto para não ir parar em log.
  @override
  String toString() => 'LoginResponse(lojista: $lojista, expiraEm: $expiraEm)';
}
