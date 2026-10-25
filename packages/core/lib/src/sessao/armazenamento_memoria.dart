import 'package:tabloide_core/src/sessao/armazenamento_local.dart';

final class ArmazenamentoMemoria implements ArmazenamentoLocal {
  ArmazenamentoMemoria([Map<String, String>? valores])
    : valores = {...?valores};

  final Map<String, String> valores;

  @override
  Future<String?> ler(String chave) async => valores[chave];

  @override
  Future<void> gravar(String chave, String valor) async =>
      valores[chave] = valor;

  @override
  Future<void> remover(String chave) async => valores.remove(chave);
}
