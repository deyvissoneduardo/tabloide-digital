import 'package:tabloide_core/src/responses/lojista_response.dart';

final class LoginResponse {
  const LoginResponse({
    required this.lojista,
    required this.token,
    required this.expiraEm,
  });

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

  final LojistaResponse lojista;

  final String token;

  final DateTime expiraEm;

  @override
  bool operator ==(Object other) =>
      other is LoginResponse &&
      other.lojista == lojista &&
      other.token == token &&
      other.expiraEm == expiraEm;

  @override
  int get hashCode => Object.hash(lojista, token, expiraEm);

  @override
  String toString() => 'LoginResponse(lojista: $lojista, expiraEm: $expiraEm)';
}
