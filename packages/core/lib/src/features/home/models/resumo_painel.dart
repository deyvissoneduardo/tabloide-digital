/// Números da seção Início do painel.
final class ResumoPainel {
  /// Cria o resumo.
  const ResumoPainel({
    required this.filiais,
    required this.panfletosVigentes,
    required this.produtosVigentes,
  });

  /// Filiais cadastradas.
  final int filiais;

  /// Panfletos no ar hoje.
  final int panfletosVigentes;

  /// Produtos no ar hoje.
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
