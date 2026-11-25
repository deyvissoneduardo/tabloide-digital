final class CadastroRequest {
  const CadastroRequest({
    required this.nomeFantasia,
    required this.nomeResponsavel,
    required this.email,
    required this.senha,
    required this.whatsapp,
    required this.cnpj,
    required this.aceiteTermos,
  });

  final String nomeFantasia;

  final String nomeResponsavel;

  final String email;

  final String senha;

  final String whatsapp;

  final String cnpj;

  /// LGPD: aceite dos Termos de Uso e da Política de Privacidade; a API recusa se não for `true`.
  final bool aceiteTermos;

  Map<String, Object?> toJson() => {
    'nomeFantasia': nomeFantasia,
    'nomeResponsavel': nomeResponsavel,
    'email': email,
    'senha': senha,
    'whatsapp': whatsapp,
    'cnpj': cnpj,
    'aceiteTermos': aceiteTermos,
  };

  @override
  bool operator ==(Object other) =>
      other is CadastroRequest &&
      other.nomeFantasia == nomeFantasia &&
      other.nomeResponsavel == nomeResponsavel &&
      other.email == email &&
      other.senha == senha &&
      other.whatsapp == whatsapp &&
      other.cnpj == cnpj &&
      other.aceiteTermos == aceiteTermos;

  @override
  int get hashCode => Object.hash(
    nomeFantasia,
    nomeResponsavel,
    email,
    senha,
    whatsapp,
    cnpj,
    aceiteTermos,
  );

  @override
  String toString() =>
      'CadastroRequest(nomeFantasia: $nomeFantasia, email: $email)';
}
