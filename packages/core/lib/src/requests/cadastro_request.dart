final class CadastroRequest {
  const CadastroRequest({
    required this.nomeFantasia,
    required this.nomeResponsavel,
    required this.email,
    required this.senha,
    required this.whatsapp,
    required this.cnpj,
  });

  final String nomeFantasia;

  final String nomeResponsavel;

  final String email;

  final String senha;

  final String whatsapp;

  final String cnpj;

  Map<String, Object?> toJson() => {
    'nomeFantasia': nomeFantasia,
    'nomeResponsavel': nomeResponsavel,
    'email': email,
    'senha': senha,
    'whatsapp': whatsapp,
    'cnpj': cnpj,
  };

  @override
  bool operator ==(Object other) =>
      other is CadastroRequest &&
      other.nomeFantasia == nomeFantasia &&
      other.nomeResponsavel == nomeResponsavel &&
      other.email == email &&
      other.senha == senha &&
      other.whatsapp == whatsapp &&
      other.cnpj == cnpj;

  @override
  int get hashCode =>
      Object.hash(nomeFantasia, nomeResponsavel, email, senha, whatsapp, cnpj);

  @override
  String toString() =>
      'CadastroRequest(nomeFantasia: $nomeFantasia, email: $email)';
}
