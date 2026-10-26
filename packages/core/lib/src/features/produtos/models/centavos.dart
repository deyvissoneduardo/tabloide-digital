final _naoDigito = RegExp(r'\D');

final _milhar = RegExp(r'\B(?=(\d{3})+(?!\d))');

abstract final class Centavos {
  static String formatar(int centavos) {
    final reais = (centavos ~/ 100).toString();
    final milhares = reais.replaceAll(_milhar, '.');
    final resto = (centavos % 100).toString().padLeft(2, '0');
    return 'R\$ $milhares,$resto';
  }

  static int? ler(String texto) {
    final digitos = texto.replaceAll(_naoDigito, '');
    return digitos.isEmpty ? null : int.parse(digitos);
  }
}
