final class ResumoPainel {
  const ResumoPainel({
    required this.panfletosVigentes,
    required this.produtosVigentes,
  });

  final int panfletosVigentes;

  final int produtosVigentes;

  @override
  bool operator ==(Object other) =>
      other is ResumoPainel &&
      other.panfletosVigentes == panfletosVigentes &&
      other.produtosVigentes == produtosVigentes;

  @override
  int get hashCode => Object.hash(panfletosVigentes, produtosVigentes);

  @override
  String toString() =>
      'ResumoPainel(panfletos: $panfletosVigentes, produtos: $produtosVigentes)';
}
