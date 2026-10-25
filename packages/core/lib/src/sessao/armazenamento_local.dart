abstract interface class ArmazenamentoLocal {
  Future<String?> ler(String chave);

  Future<void> gravar(String chave, String valor);

  Future<void> remover(String chave);
}
