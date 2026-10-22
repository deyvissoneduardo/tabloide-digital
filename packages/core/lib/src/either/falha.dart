/// Erro de domínio devolvido no lado [Failure] de um `Either`.
///
/// É sealed: quem trata a falha usa `switch` e o compilador avisa quando
/// surgir um tipo novo sem tratamento.
sealed class Falha {
  const Falha(this.mensagem);

  /// Texto para mostrar ao lojista.
  final String mensagem;

  @override
  String toString() => '$runtimeType($mensagem)';
}

/// Sem conexão com o servidor.
final class FalhaSemConexao extends Falha {
  /// Cria a falha com a mensagem padrão.
  const FalhaSemConexao()
    : super('Sem conexão. Verifique a internet e tente de novo.');

  @override
  bool operator ==(Object other) => other is FalhaSemConexao;

  @override
  int get hashCode => (FalhaSemConexao).hashCode;
}

/// Erro não previsto; [causa] fica para log, nunca para a tela.
final class FalhaInesperada extends Falha {
  /// Cria a falha guardando a [causa] original.
  const FalhaInesperada(this.causa) : super('Algo deu errado. Tente de novo.');

  /// Exceção original.
  final Object causa;

  @override
  bool operator ==(Object other) =>
      other is FalhaInesperada && other.causa == causa;

  @override
  int get hashCode => Object.hash(FalhaInesperada, causa);
}
