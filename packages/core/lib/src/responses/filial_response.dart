import 'package:tabloide_core/src/features/filiais/models/endereco.dart';

final class FilialResponse {
  const FilialResponse({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.fusoHorario,
    required this.codigoPublico,
    required this.urlPublica,
    required this.criadaEm,
    required this.atualizadaEm,
  });

  factory FilialResponse.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'nome': final String nome,
      'endereco': final Object endereco,
      'fusoHorario': final String fusoHorario,
      'codigoPublico': final String codigoPublico,
      'urlPublica': final String urlPublica,
      'criadaEm': final String criadaEm,
      'atualizadaEm': final String atualizadaEm,
    } =>
      FilialResponse(
        id: id,
        nome: nome,
        endereco: Endereco.fromJson(endereco),
        fusoHorario: fusoHorario,
        codigoPublico: codigoPublico,
        urlPublica: urlPublica,
        criadaEm: DateTime.parse(criadaEm),
        atualizadaEm: DateTime.parse(atualizadaEm),
      ),
    _ => throw const FormatException('Filial fora do formato esperado'),
  };

  final String id;

  final String nome;

  final Endereco endereco;

  final String fusoHorario;

  final String codigoPublico;

  final String urlPublica;

  final DateTime criadaEm;

  final DateTime atualizadaEm;

  @override
  bool operator ==(Object other) =>
      other is FilialResponse &&
      other.id == id &&
      other.nome == nome &&
      other.endereco == endereco &&
      other.fusoHorario == fusoHorario &&
      other.codigoPublico == codigoPublico &&
      other.urlPublica == urlPublica &&
      other.criadaEm == criadaEm &&
      other.atualizadaEm == atualizadaEm;

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    endereco,
    fusoHorario,
    codigoPublico,
    urlPublica,
    criadaEm,
    atualizadaEm,
  );

  @override
  String toString() => 'FilialResponse(id: $id, nome: $nome)';
}
