import 'package:tabloide_core/src/features/filiais/models/endereco.dart';

final class FilialRequest {
  const FilialRequest({
    required this.nome,
    required this.endereco,
    required this.fusoHorario,
    this.sePanfleto = false,
  });

  final String nome;

  final Endereco endereco;

  final String fusoHorario;

  /// RN44: mostrar só o panfleto vigente na página pública desta filial.
  final bool sePanfleto;

  Map<String, Object?> toJson() => {
    'nome': nome,
    'endereco': endereco.toJson(),
    'fusoHorario': fusoHorario,
    'sePanfleto': sePanfleto,
  };

  @override
  bool operator ==(Object other) =>
      other is FilialRequest &&
      other.nome == nome &&
      other.endereco == endereco &&
      other.fusoHorario == fusoHorario &&
      other.sePanfleto == sePanfleto;

  @override
  int get hashCode => Object.hash(nome, endereco, fusoHorario, sePanfleto);

  @override
  String toString() =>
      'FilialRequest(nome: $nome, endereco: $endereco, sePanfleto: $sePanfleto)';
}
