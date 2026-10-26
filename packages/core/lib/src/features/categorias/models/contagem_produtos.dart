final class ContagemProdutos {
  const ContagemProdutos({
    required this.vigentes,
    required this.agendados,
    required this.vencidos,
  });

  factory ContagemProdutos.fromJson(Object? json) => switch (json) {
    {
      'vigentes': final int vigentes,
      'agendados': final int agendados,
      'vencidos': final int vencidos,
    } =>
      ContagemProdutos(
        vigentes: vigentes,
        agendados: agendados,
        vencidos: vencidos,
      ),
    _ => throw const FormatException('Contagem de produtos fora do formato'),
  };

  final int vigentes;

  final int agendados;

  final int vencidos;

  int get ativos => vigentes + agendados;

  @override
  bool operator ==(Object other) =>
      other is ContagemProdutos &&
      other.vigentes == vigentes &&
      other.agendados == agendados &&
      other.vencidos == vencidos;

  @override
  int get hashCode => Object.hash(vigentes, agendados, vencidos);

  @override
  String toString() =>
      'ContagemProdutos(vigentes: $vigentes, agendados: $agendados, '
      'vencidos: $vencidos)';
}
