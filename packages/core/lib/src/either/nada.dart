final class Nada {
  const Nada();

  @override
  bool operator ==(Object other) => other is Nada;

  @override
  int get hashCode => (Nada).hashCode;

  @override
  String toString() => 'Nada';
}
