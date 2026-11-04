/// O que a home precisa do lojista para os cards de página (modelo, não
/// record: regra das camadas).
final class ContextoPaginas {
  const ContextoPaginas({required this.contaAtiva, required this.nomeFantasia});

  final bool contaAtiva;

  final String nomeFantasia;
}
