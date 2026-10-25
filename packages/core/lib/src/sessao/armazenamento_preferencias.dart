import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabloide_core/src/sessao/armazenamento_local.dart';

final class ArmazenamentoPreferencias implements ArmazenamentoLocal {
  ArmazenamentoPreferencias({SharedPreferencesAsync? preferencias})
    : _injetadas = preferencias;

  final SharedPreferencesAsync? _injetadas;

  late final _preferencias = _injetadas ?? SharedPreferencesAsync();

  @override
  Future<String?> ler(String chave) => _preferencias.getString(chave);

  @override
  Future<void> gravar(String chave, String valor) =>
      _preferencias.setString(chave, valor);

  @override
  Future<void> remover(String chave) => _preferencias.remove(chave);
}
