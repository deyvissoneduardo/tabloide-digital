final _mascara = RegExp(r'[./-]');
final _formato = RegExp(r'^[0-9A-Z]{12}[0-9]{2}$');

const _pesosPrimeiroDv = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
const _pesosSegundoDv = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

/// Valida CNPJ numérico e alfanumérico (com ou sem máscara).
///
/// No alfanumérico, cada caractere vale `codeUnit - 48`; o cálculo do dígito
/// verificador é o mesmo do numérico.
bool cnpjValido(String valor) {
  final cnpj = valor.replaceAll(_mascara, '').toUpperCase();
  if (!_formato.hasMatch(cnpj)) return false;
  if (cnpj.split('').every((c) => c == cnpj[0])) return false;

  final primeiro = _digitoVerificador(cnpj.substring(0, 12), _pesosPrimeiroDv);
  final segundo = _digitoVerificador(
    '${cnpj.substring(0, 12)}$primeiro',
    _pesosSegundoDv,
  );
  return cnpj.substring(12) == '$primeiro$segundo';
}

int _digitoVerificador(String base, List<int> pesos) {
  var soma = 0;
  for (var i = 0; i < pesos.length; i++) {
    soma += (base.codeUnitAt(i) - 48) * pesos[i];
  }
  final resto = soma % 11;
  return resto < 2 ? 0 : 11 - resto;
}
