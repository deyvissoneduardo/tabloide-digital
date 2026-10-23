/// Lojista devolvido pela API (ex.: no login).
final class LojistaResponse {
  /// Cria o lojista.
  const LojistaResponse({
    required this.id,
    required this.nomeFantasia,
    required this.nomeResponsavel,
    required this.email,
    required this.whatsapp,
    required this.cnpj,
    required this.status,
    required this.criadoEm,
  });

  /// Lê o JSON da API; lança [FormatException] se faltar campo.
  factory LojistaResponse.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'nomeFantasia': final String nomeFantasia,
      'nomeResponsavel': final String nomeResponsavel,
      'email': final String email,
      'whatsapp': final String whatsapp,
      'cnpj': final String cnpj,
      'status': final String status,
      'criadoEm': final String criadoEm,
    } =>
      LojistaResponse(
        id: id,
        nomeFantasia: nomeFantasia,
        nomeResponsavel: nomeResponsavel,
        email: email,
        whatsapp: whatsapp,
        cnpj: cnpj,
        status: status,
        criadoEm: DateTime.parse(criadoEm),
      ),
    _ => throw const FormatException('Lojista fora do formato esperado'),
  };

  /// Identificador do lojista.
  final String id;

  /// Nome da loja exibido ao consumidor.
  final String nomeFantasia;

  /// Pessoa responsável pela conta.
  final String nomeResponsavel;

  /// E-mail de acesso.
  final String email;

  /// WhatsApp no formato E.164 (ex.: `+5511987654321`).
  final String whatsapp;

  /// Só dígitos, sem máscara.
  final String cnpj;

  /// Situação da conta na API (ex.: `AGUARDANDO_ATIVACAO`).
  final String status;

  /// Quando a conta foi criada.
  final DateTime criadoEm;

  @override
  bool operator ==(Object other) =>
      other is LojistaResponse &&
      other.id == id &&
      other.nomeFantasia == nomeFantasia &&
      other.nomeResponsavel == nomeResponsavel &&
      other.email == email &&
      other.whatsapp == whatsapp &&
      other.cnpj == cnpj &&
      other.status == status &&
      other.criadoEm == criadoEm;

  @override
  int get hashCode => Object.hash(
    id,
    nomeFantasia,
    nomeResponsavel,
    email,
    whatsapp,
    cnpj,
    status,
    criadoEm,
  );

  @override
  String toString() => 'LojistaResponse(id: $id, nomeFantasia: $nomeFantasia)';
}
