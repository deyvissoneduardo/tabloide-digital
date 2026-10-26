final _iso = RegExp(r'^\d{4}-\d{2}-\d{2}$');

abstract final class DataDia {
  static DateTime ler(String texto) {
    if (!_iso.hasMatch(texto)) {
      throw FormatException('Data fora do formato aaaa-mm-dd', texto);
    }
    return DateTime.parse(texto);
  }

  static DateTime hoje() => DataDia.de(DateTime.now());

  static DateTime de(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  static String iso(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-${_dois(data.month)}-${_dois(data.day)}';

  static String curta(DateTime data) =>
      '${_dois(data.day)}/${_dois(data.month)}';

  static String completa(DateTime data) =>
      '${curta(data)}/${data.year.toString().padLeft(4, '0')}';

  static String _dois(int valor) => valor.toString().padLeft(2, '0');
}
