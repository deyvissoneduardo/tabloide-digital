import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_app/tabloide_app.dart';

import '../../../helpers/montar.dart';

final class _AuthRepositoryPendente implements AuthRepository {
  @override
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) =>
      Completer<Either<Falha, LoginResponse>>().future;
}

LoginController _enviando() =>
    loginControllerDeTeste(repository: _AuthRepositoryPendente())
      ..entrar(email: 'ana@bompreco.com.br', senha: 'Teste1234');

void main() {
  goldenTest(
    'Cenário: Dado o login do app no tema claro, então o formulário segue a marca',
    fileName: 'login_screen_app_light',
    pumpBeforeTest: pumpNTimes(2, const Duration(milliseconds: 300)),
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in marcasDeTeste.entries)
          for (final (estado, controller) in [
            ('inicial', loginControllerDeTeste),
            ('enviando', _enviando),
          ])
            GoldenTestScenario(
              name: 'Marca $nome, $estado',
              constraints: const BoxConstraints.tightFor(
                width: 360,
                height: 800,
              ),
              child: montarLogin(marca: marca, controller: controller()),
            ),
      ],
    ),
  );
}
