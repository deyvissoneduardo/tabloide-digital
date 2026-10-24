final class ResumoPainel {
  const ResumoPainel({
    required this.filiais,
    required this.panfletosVigentes,
    required this.produtosVigentes,
  });

  final int filiais;

  final int panfletosVigentes;

  final int produtosVigentes;

  @override
  bool operator ==(Object other) =>
      other is ResumoPainel &&
      other.filiais == filiais &&
      other.panfletosVigentes == panfletosVigentes &&
      other.produtosVigentes == produtosVigentes;

  @override
  int get hashCode => Object.hash(filiais, panfletosVigentes, produtosVigentes);

  @override
  String toString() =>
      'ResumoPainel(filiais: $filiais, panfletos: $panfletosVigentes, produtos: $produtosVigentes)';
}
