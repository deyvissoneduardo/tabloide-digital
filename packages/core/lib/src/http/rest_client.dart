abstract interface class RestClient {
  Future<RestResposta> get(String caminho, {Map<String, dynamic>? query});

  Future<RestResposta> post(String caminho, {Object? corpo});

  Future<RestResposta> patch(String caminho, {Object? corpo});

  Future<RestResposta> put(String caminho, {Object? corpo});

  Future<RestResposta> delete(String caminho);

  /// Baixa um arquivo (ex.: PNG do QR Code). Em 2xx, `dados` é `Uint8List`;
  /// em erro HTTP, `dados` é o JSON de erro da API decodificado (ou null).
  Future<RestResposta> baixar(String caminho, {Map<String, dynamic>? query});

  Future<RestResposta> enviarArquivo(
    String caminho, {
    required String campo,
    required List<int> bytes,
    required String nomeArquivo,
    MetodoEnvio metodo = MetodoEnvio.put,
    Map<String, String> campos = const {},
  });
}

enum MetodoEnvio { post, put }

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
