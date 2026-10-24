import 'package:tabloide_core/src/responses/lojista_response.dart';

final class CadastroResponse {
  const CadastroResponse({
    required this.lojista,
    required this.token,
    required this.expiraEm,
  });

  factory CadastroResponse.fromJson(Object? json) => switch (json) {
    {
      'lojista': final Object lojista,
      'token': final String token,
      'expiraEm': final String expiraEm,
    } =>
      CadastroResponse(
        lojista: LojistaResponse.fromJson(lojista),
        token: token,
        expiraEm: DateTime.parse(expiraEm),
      ),
    _ => throw const FormatException('Cadastro fora do formato esperado'),
  };

  final LojistaResponse lojista;

  final String token;

  final DateTime expiraEm;

  @override
  bool operator ==(Object other) =>
      other is CadastroResponse &&
      other.lojista == lojista &&
      other.token == token &&
      other.expiraEm == expiraEm;

  @override
  int get hashCode => Object.hash(lojista, token, expiraEm);

  @override
  String toString() =>
      'CadastroResponse(lojista: $lojista, expiraEm: $expiraEm)';
}
