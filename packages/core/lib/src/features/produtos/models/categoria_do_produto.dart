final class CategoriaDoProduto {
  const CategoriaDoProduto({required this.id, required this.nome});

  factory CategoriaDoProduto.fromJson(Object? json) => switch (json) {
    {'id': final String id, 'nome': final String nome} => CategoriaDoProduto(
      id: id,
      nome: nome,
    ),
    _ => throw const FormatException('Categoria do produto fora do formato'),
  };

  final String id;

  final String nome;

  @override
  bool operator ==(Object other) =>
      other is CategoriaDoProduto && other.id == id && other.nome == nome;

  @override
  int get hashCode => Object.hash(id, nome);

  @override
  String toString() => 'CategoriaDoProduto($id, $nome)';
}
