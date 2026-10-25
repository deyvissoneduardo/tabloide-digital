final class CepResponse {
  const CepResponse({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory CepResponse.fromJson(Object? json) => switch (json) {
    {
      'cep': final String cep,
      'logradouro': final String logradouro,
      'bairro': final String bairro,
      'localidade': final String cidade,
      'uf': final String uf,
    } =>
      CepResponse(
        cep: cep,
        logradouro: logradouro,
        bairro: bairro,
        cidade: cidade,
        uf: uf,
      ),
    _ => throw const FormatException('CEP fora do formato esperado'),
  };

  final String cep;

  final String logradouro;

  final String bairro;

  final String cidade;

  final String uf;

  @override
  bool operator ==(Object other) =>
      other is CepResponse &&
      other.cep == cep &&
      other.logradouro == logradouro &&
      other.bairro == bairro &&
      other.cidade == cidade &&
      other.uf == uf;

  @override
  int get hashCode => Object.hash(cep, logradouro, bairro, cidade, uf);

  @override
  String toString() => 'CepResponse($cep, $cidade/$uf)';
}
