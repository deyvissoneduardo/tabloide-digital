final class ResumoFilial {
  const ResumoFilial({
    required this.filialId,
    required this.panfletosVigentes,
    required this.produtosVigentes,
  });

  final String filialId;

  final int panfletosVigentes;

  final int produtosVigentes;

  @override
  bool operator ==(Object other) =>
      other is ResumoFilial &&
      other.filialId == filialId &&
      other.panfletosVigentes == panfletosVigentes &&
      other.produtosVigentes == produtosVigentes;

  @override
  int get hashCode =>
      Object.hash(filialId, panfletosVigentes, produtosVigentes);

  @override
  String toString() =>
      'ResumoFilial($filialId, panfletos: $panfletosVigentes, '
      'produtos: $produtosVigentes)';
}
