/// Cliente HTTP do painel, independente da biblioteca usada por baixo.
///
/// Toda resposta do servidor, inclusive 4xx/5xx, volta como [RestResposta];
/// quando o servidor não é alcançado, o método lança [ErroSemConexao].
abstract interface class RestClient {
  /// GET em [caminho], relativo à URL base.
  Future<RestResposta> get(String caminho, {Map<String, dynamic>? query});

  /// POST em [caminho] com [corpo] serializado em JSON.
  Future<RestResposta> post(String caminho, {Object? corpo});

  /// PATCH em [caminho] com [corpo] serializado em JSON.
  Future<RestResposta> patch(String caminho, {Object? corpo});

  /// PUT em [caminho] com [corpo] serializado em JSON.
  Future<RestResposta> put(String caminho, {Object? corpo});

  /// DELETE em [caminho].
  Future<RestResposta> delete(String caminho);
}

/// Resposta HTTP já desacoplada da biblioteca.
final class RestResposta {
  /// Cria a resposta com o [status] HTTP e os [dados] decodificados.
  const RestResposta({required this.status, this.dados});

  /// Código de status HTTP.
  final int status;

  /// Corpo decodificado (JSON vira `Map`/`List`).
  final Object? dados;
}

/// O servidor não foi alcançado (sem rede, DNS ou tempo esgotado).
///
/// `tentar` converte este erro em `FalhaSemConexao`.
final class ErroSemConexao implements Exception {
  /// Cria o erro.
  const ErroSemConexao();

  @override
  String toString() => 'ErroSemConexao';
}
