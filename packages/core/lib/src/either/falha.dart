sealed class Falha {
  const Falha(this.mensagem);

  final String mensagem;

  @override
  String toString() => '$runtimeType($mensagem)';
}

final class FalhaSemConexao extends Falha {
  const FalhaSemConexao()
    : super('Sem conexão. Verifique a internet e tente de novo.');

  @override
  bool operator ==(Object other) => other is FalhaSemConexao;

  @override
  int get hashCode => (FalhaSemConexao).hashCode;
}

final class FalhaInesperada extends Falha {
  const FalhaInesperada(this.causa) : super('Algo deu errado. Tente de novo.');

  final Object causa;

  @override
  bool operator ==(Object other) =>
      other is FalhaInesperada && other.causa == causa;

  @override
  int get hashCode => Object.hash(FalhaInesperada, causa);
}

final class FalhaApi extends Falha {
  const FalhaApi({
    required this.codigo,
    required String mensagem,
    this.campos = const {},
  }) : super(mensagem);

  final String codigo;

  final Map<String, List<String>> campos;

  @override
  bool operator ==(Object other) =>
      other is FalhaApi &&
      other.codigo == codigo &&
      other.mensagem == mensagem &&
      _camposIguais(other.campos, campos);

  @override
  int get hashCode => Object.hash(
    FalhaApi,
    codigo,
    mensagem,
    Object.hashAllUnordered([
      for (final MapEntry(:key, :value) in campos.entries)
        Object.hash(key, Object.hashAll(value)),
    ]),
  );
}

bool _camposIguais(Map<String, List<String>> a, Map<String, List<String>> b) {
  if (a.length != b.length) return false;
  for (final MapEntry(:key, :value) in a.entries) {
    final outro = b[key];
    if (outro == null || outro.length != value.length) return false;
    for (var i = 0; i < value.length; i++) {
      if (outro[i] != value[i]) return false;
    }
  }
  return true;
}
