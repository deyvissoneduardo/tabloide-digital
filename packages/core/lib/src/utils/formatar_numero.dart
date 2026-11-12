String formatarInteiro(int valor) {
  final digitos = valor.abs().toString();
  final grupos = <String>[];
  for (var fim = digitos.length; fim > 0; fim -= 3) {
    grupos.insert(0, digitos.substring(fim - 3 < 0 ? 0 : fim - 3, fim));
  }
  return '${valor < 0 ? '-' : ''}${grupos.join('.')}';
}

String formatarDecimal(double valor, {int casas = 1}) {
  final texto = valor.abs().toStringAsFixed(casas);
  final [inteiro, ...decimais] = texto.split('.');
  final sinal = valor < 0 && texto.contains(RegExp('[1-9]')) ? '-' : '';
  final parteInteira = formatarInteiro(int.parse(inteiro));
  return decimais.isEmpty
      ? '$sinal$parteInteira'
      : '$sinal$parteInteira,${decimais.single}';
}
