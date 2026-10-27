final class IdentidadeResponse {
  const IdentidadeResponse({
    required this.nomeFantasia,
    this.sePanfleto = false,
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
      'sePanfleto': final bool sePanfleto,
    } =>
      IdentidadeResponse(
        nomeFantasia: nomeFantasia,
        corPrimaria: corPrimaria,
        corSecundaria: corSecundaria,
        urlLogo: urlLogo,
        sePanfleto: sePanfleto,
      ),
    _ => throw const FormatException('Identidade fora do formato esperado'),
  };

  final String nomeFantasia;

  final String? corPrimaria;

  final String? corSecundaria;

  final String? urlLogo;

  /// Mostrar só o panfleto na página pública (RN44, por lojista).
  final bool sePanfleto;

  @override
  bool operator ==(Object other) =>
      other is IdentidadeResponse &&
      other.nomeFantasia == nomeFantasia &&
      other.corPrimaria == corPrimaria &&
      other.corSecundaria == corSecundaria &&
      other.urlLogo == urlLogo &&
      other.sePanfleto == sePanfleto;

  @override
  int get hashCode => Object.hash(
    nomeFantasia,
    corPrimaria,
    corSecundaria,
    urlLogo,
    sePanfleto,
  );

  @override
  String toString() =>
      'IdentidadeResponse(nomeFantasia: $nomeFantasia, '
      'corPrimaria: $corPrimaria, corSecundaria: $corSecundaria, '
      'sePanfleto: $sePanfleto)';
}
