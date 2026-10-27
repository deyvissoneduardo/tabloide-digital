final class IdentidadeRequest {
  const IdentidadeRequest({
    required this.nomeFantasia,
    required this.sePanfleto,
    this.corPrimaria,
    this.corSecundaria,
  });

  final String nomeFantasia;

  final String? corPrimaria;

  final String? corSecundaria;

  final bool sePanfleto;

  Map<String, Object?> toJson() => {
    'nomeFantasia': nomeFantasia,
    'corPrimaria': corPrimaria,
    'corSecundaria': corSecundaria,
    'sePanfleto': sePanfleto,
  };

  @override
  bool operator ==(Object other) =>
      other is IdentidadeRequest &&
      other.nomeFantasia == nomeFantasia &&
      other.corPrimaria == corPrimaria &&
      other.corSecundaria == corSecundaria &&
      other.sePanfleto == sePanfleto;

  @override
  int get hashCode =>
      Object.hash(nomeFantasia, corPrimaria, corSecundaria, sePanfleto);

  @override
  String toString() =>
      'IdentidadeRequest(nomeFantasia: $nomeFantasia, '
      'corPrimaria: $corPrimaria, corSecundaria: $corSecundaria, '
      'sePanfleto: $sePanfleto)';
}
