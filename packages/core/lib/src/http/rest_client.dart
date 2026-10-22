/// Cliente HTTP do painel, independente da biblioteca usada por baixo.
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
