final class LojistaResponse {
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

  final String id;

  final String nomeFantasia;

  final String nomeResponsavel;

  final String email;

  final String whatsapp;

  final String cnpj;

  final String status;

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
