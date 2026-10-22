/// Erro de configuração de marca white-label.
sealed class BrandErro implements Exception {
  const BrandErro(this.id);

  /// Id da marca envolvida.
  final String id;
}

/// A marca pedida não foi registrada.
final class MarcaNaoRegistrada extends BrandErro {
  /// Cria o erro com as marcas disponíveis no registro.
  const MarcaNaoRegistrada(super.id, this.disponiveis);

  /// Ids registrados, para a mensagem de erro.
  final List<String> disponiveis;

  @override
  String toString() =>
      'Marca "$id" não registrada. Disponíveis: ${disponiveis.join(', ')}';
}

/// Já existe uma marca registrada com o mesmo id.
final class MarcaDuplicada extends BrandErro {
  /// Cria o erro para o id repetido.
  const MarcaDuplicada(super.id);

  @override
  String toString() => 'Marca "$id" já registrada.';
}

/// A marca tem algum dado inválido.
final class MarcaInvalida extends BrandErro {
  /// Cria o erro com o motivo da recusa.
  const MarcaInvalida(super.id, this.motivo);

  /// O que está errado na marca.
  final String motivo;

  @override
  String toString() => 'Marca "$id" inválida: $motivo.';
}
