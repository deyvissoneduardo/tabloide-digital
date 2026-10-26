final class CategoriaRequest {
  const CategoriaRequest({required this.nome});

  final String nome;

  Map<String, String> toJson() => {'nome': nome.trim()};

  @override
  bool operator ==(Object other) =>
      other is CategoriaRequest && other.nome == nome;

  @override
  int get hashCode => nome.hashCode;

  @override
  String toString() => 'CategoriaRequest($nome)';
}
