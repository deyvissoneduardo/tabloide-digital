final class IdentidadeRequest {
  const IdentidadeRequest({
    required this.nomeFantasia,
    this.corPrimaria,
    this.corSecundaria,
  });

  final String nomeFantasia;

  final String? corPrimaria;

  final String? corSecundaria;

  Map<String, Object?> toJson() => {
    'nomeFantasia': nomeFantasia,
    'corPrimaria': corPrimaria,
    'corSecundaria': corSecundaria,
  };

  @override
  bool operator ==(Object other) =>
      other is IdentidadeRequest &&
      other.nomeFantasia == nomeFantasia &&
      other.corPrimaria == corPrimaria &&
      other.corSecundaria == corSecundaria;

  @override
  int get hashCode => Object.hash(nomeFantasia, corPrimaria, corSecundaria);

  @override
  String toString() =>
      'IdentidadeRequest(nomeFantasia: $nomeFantasia, '
      'corPrimaria: $corPrimaria, corSecundaria: $corSecundaria)';
}
