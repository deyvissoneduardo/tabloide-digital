import 'package:tabloide_core/src/features/filiais/models/endereco.dart';

final class FilialRequest {
  const FilialRequest({
    required this.nome,
    required this.endereco,
    required this.fusoHorario,
  });

  final String nome;

  final Endereco endereco;

  final String fusoHorario;

  Map<String, Object?> toJson() => {
    'nome': nome,
    'endereco': endereco.toJson(),
    'fusoHorario': fusoHorario,
  };

  @override
  bool operator ==(Object other) =>
      other is FilialRequest &&
      other.nome == nome &&
      other.endereco == endereco &&
      other.fusoHorario == fusoHorario;

  @override
  int get hashCode => Object.hash(nome, endereco, fusoHorario);

  @override
  String toString() => 'FilialRequest(nome: $nome, endereco: $endereco)';
}
