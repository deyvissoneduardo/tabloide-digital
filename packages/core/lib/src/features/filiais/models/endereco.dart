final class Endereco {
  const Endereco({
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.complemento,
  });

  factory Endereco.fromJson(Object? json) => switch (json) {
    {
          'cep': final String cep,
          'logradouro': final String logradouro,
          'numero': final String numero,
          'bairro': final String bairro,
          'cidade': final String cidade,
          'uf': final String uf,
        } &&
        final Map<dynamic, dynamic> mapa =>
      Endereco(
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: switch (mapa['complemento']) {
          final String complemento when complemento.isNotEmpty => complemento,
          _ => null,
        },
        bairro: bairro,
        cidade: cidade,
        uf: uf,
      ),
    _ => throw const FormatException('Endereço fora do formato esperado'),
  };

  final String cep;

  final String logradouro;

  final String numero;

  final String? complemento;

  final String bairro;

  final String cidade;

  final String uf;

  Map<String, Object?> toJson() => {
    'cep': cep,
    'logradouro': logradouro,
    'numero': numero,
    'complemento': ?complemento,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
  };

  @override
  bool operator ==(Object other) =>
      other is Endereco &&
      other.cep == cep &&
      other.logradouro == logradouro &&
      other.numero == numero &&
      other.complemento == complemento &&
      other.bairro == bairro &&
      other.cidade == cidade &&
      other.uf == uf;

  @override
  int get hashCode =>
      Object.hash(cep, logradouro, numero, complemento, bairro, cidade, uf);

  @override
  String toString() => 'Endereco($logradouro, $numero - $cidade/$uf)';
}
