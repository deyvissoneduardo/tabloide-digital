import 'dart:async';

// Sobrescreve o config da pasta pai: o alchemist usa `dart:io` e não compila
// no navegador.
Future<void> testExecutable(FutureOr<void> Function() testMain) async =>
    testMain();
