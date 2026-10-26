final class LojistaRequest {
  const LojistaRequest({
    required this.nomeFantasia,
    required this.nomeResponsavel,
    required this.whatsapp,
    required this.cnpj,
  });

  final String nomeFantasia;

  final String nomeResponsavel;

  final String whatsapp;

  final String cnpj;

  Map<String, Object?> toJson() => {
    'nomeFantasia': nomeFantasia,
    'nomeResponsavel': nomeResponsavel,
    'whatsapp': whatsapp,
    'cnpj': cnpj,
  };

  @override
  bool operator ==(Object other) =>
      other is LojistaRequest &&
      other.nomeFantasia == nomeFantasia &&
      other.nomeResponsavel == nomeResponsavel &&
      other.whatsapp == whatsapp &&
      other.cnpj == cnpj;

  @override
  int get hashCode =>
      Object.hash(nomeFantasia, nomeResponsavel, whatsapp, cnpj);

  @override
  String toString() =>
      'LojistaRequest(nomeFantasia: $nomeFantasia, '
      'nomeResponsavel: $nomeResponsavel)';
}
