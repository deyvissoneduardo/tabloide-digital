/// Resultado de uma operação que pode falhar: [Failure] ou [Success].
///
/// Todo repository e todo service devolve `Future<Either<Falha, T>>`, com
/// `T` sendo um modelo tipado, nunca `Map`, `List` crua ou `dynamic`.
sealed class Either<F, S> {
  const Either();

  /// Executa [quandoFalha] ou [quandoSucesso], conforme o resultado.
  R fold<R>(
    R Function(F falha) quandoFalha,
    R Function(S valor) quandoSucesso,
  ) => switch (this) {
    Failure(:final falha) => quandoFalha(falha),
    Success(:final valor) => quandoSucesso(valor),
  };

  /// Transforma o valor de sucesso; a falha passa adiante sem mudança.
  Either<F, T> map<T>(T Function(S valor) transformar) => switch (this) {
    Failure(:final falha) => Failure(falha),
    Success(:final valor) => Success(transformar(valor)),
  };

  /// Encadeia outra operação que também pode falhar.
  Either<F, T> flatMap<T>(Either<F, T> Function(S valor) proxima) =>
      switch (this) {
        Failure(:final falha) => Failure(falha),
        Success(:final valor) => proxima(valor),
      };

  /// `true` se for [Success].
  bool get isSuccess => this is Success<F, S>;

  /// `true` se for [Failure].
  bool get isFailure => this is Failure<F, S>;
}

/// Lado de erro do [Either].
final class Failure<F, S> extends Either<F, S> {
  /// Cria a falha.
  const Failure(this.falha);

  /// O erro que aconteceu.
  final F falha;

  @override
  bool operator ==(Object other) =>
      other is Failure<F, S> && other.falha == falha;

  @override
  int get hashCode => Object.hash(Failure, falha);

  @override
  String toString() => 'Failure($falha)';
}

/// Lado de sucesso do [Either].
final class Success<F, S> extends Either<F, S> {
  /// Cria o sucesso.
  const Success(this.valor);

  /// O valor produzido.
  final S valor;

  @override
  bool operator ==(Object other) =>
      other is Success<F, S> && other.valor == valor;

  @override
  int get hashCode => Object.hash(Success, valor);

  @override
  String toString() => 'Success($valor)';
}
