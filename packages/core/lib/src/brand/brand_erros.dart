sealed class BrandErro implements Exception {
  const BrandErro(this.id);

  final String id;
}

final class MarcaNaoRegistrada extends BrandErro {
  const MarcaNaoRegistrada(super.id, this.disponiveis);

  final List<String> disponiveis;

  @override
  String toString() =>
      'Marca "$id" não registrada. Disponíveis: ${disponiveis.join(', ')}';
}

final class MarcaDuplicada extends BrandErro {
  const MarcaDuplicada(super.id);

  @override
  String toString() => 'Marca "$id" já registrada.';
}

final class MarcaInvalida extends BrandErro {
  const MarcaInvalida(super.id, this.motivo);

  final String motivo;

  @override
  String toString() => 'Marca "$id" inválida: $motivo.';
}
