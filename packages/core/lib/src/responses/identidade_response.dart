final class IdentidadeResponse {
  const IdentidadeResponse({
    required this.nomeFantasia,
    this.corPrimaria,
    this.corSecundaria,
    this.urlLogo,
  });

  factory IdentidadeResponse.fromJson(Object? json) => switch (json) {
    {
      'nomeFantasia': final String nomeFantasia,
      'corPrimaria': final String? corPrimaria,
      'corSecundaria': final String? corSecundaria,
      'urlLogo': final String? urlLogo,
    } =>
      IdentidadeResponse(
        nomeFantasia: nomeFantasia,
        corPrimaria: corPrimaria,
        corSecundaria: corSecundaria,
        urlLogo: urlLogo,
      ),
    _ => throw const FormatException('Identidade fora do formato esperado'),
  };

  final String nomeFantasia;

  final String? corPrimaria;

  final String? corSecundaria;

  final String? urlLogo;

  @override
  bool operator ==(Object other) =>
      other is IdentidadeResponse &&
      other.nomeFantasia == nomeFantasia &&
      other.corPrimaria == corPrimaria &&
      other.corSecundaria == corSecundaria &&
      other.urlLogo == urlLogo;

  @override
  int get hashCode =>
      Object.hash(nomeFantasia, corPrimaria, corSecundaria, urlLogo);

  @override
  String toString() =>
      'IdentidadeResponse(nomeFantasia: $nomeFantasia, '
      'corPrimaria: $corPrimaria, corSecundaria: $corSecundaria)';
}
