sealed class Either<F, S> {
  const Either();

  R fold<R>(
    R Function(F falha) quandoFalha,
    R Function(S valor) quandoSucesso,
  ) => switch (this) {
    Failure(:final falha) => quandoFalha(falha),
    Success(:final valor) => quandoSucesso(valor),
  };

  Either<F, T> map<T>(T Function(S valor) transformar) => switch (this) {
    Failure(:final falha) => Failure(falha),
    Success(:final valor) => Success(transformar(valor)),
  };

  Either<F, T> flatMap<T>(Either<F, T> Function(S valor) proxima) =>
      switch (this) {
        Failure(:final falha) => Failure(falha),
        Success(:final valor) => proxima(valor),
      };

  bool get isSuccess => this is Success<F, S>;

  bool get isFailure => this is Failure<F, S>;
}

final class Failure<F, S> extends Either<F, S> {
  const Failure(this.falha);

  final F falha;

  @override
  bool operator ==(Object other) =>
      other is Failure<F, S> && other.falha == falha;

  @override
  int get hashCode => Object.hash(Failure, falha);

  @override
  String toString() => 'Failure($falha)';
}

final class Success<F, S> extends Either<F, S> {
  const Success(this.valor);

  final S valor;

  @override
  bool operator ==(Object other) =>
      other is Success<F, S> && other.valor == valor;

  @override
  int get hashCode => Object.hash(Success, valor);

  @override
  String toString() => 'Success($valor)';
}
