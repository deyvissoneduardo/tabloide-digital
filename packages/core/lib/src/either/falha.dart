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
  const FalhaApi({required this.codigo, required String mensagem})
    : super(mensagem);

  final String codigo;

  @override
  bool operator ==(Object other) =>
      other is FalhaApi && other.codigo == codigo && other.mensagem == mensagem;

  @override
  int get hashCode => Object.hash(FalhaApi, codigo, mensagem);
}
