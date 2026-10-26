abstract interface class RestClient {
  Future<RestResposta> get(String caminho, {Map<String, dynamic>? query});

  Future<RestResposta> post(String caminho, {Object? corpo});

  Future<RestResposta> patch(String caminho, {Object? corpo});

  Future<RestResposta> put(String caminho, {Object? corpo});

  Future<RestResposta> delete(String caminho);

  Future<RestResposta> enviarArquivo(
    String caminho, {
    required String campo,
    required List<int> bytes,
    required String nomeArquivo,
  });
}

final class RestResposta {
  const RestResposta({required this.status, this.dados});

  final int status;

  final Object? dados;
}

final class ErroSemConexao implements Exception {
  const ErroSemConexao();

  @override
  String toString() => 'ErroSemConexao';
}
