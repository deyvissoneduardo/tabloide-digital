import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

const _telas = {
  'desktop': Size(1440, 900),
  'tablet': Size(768, 1024),
  'celular': Size(390, 844),
};

/// Login que nunca responde, para o golden mostrar o estado "enviando".
final class _AuthRepositoryPendente implements AuthRepository {
  @override
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request) =>
      Completer<Either<Falha, LoginResponse>>().future;
}

LoginController _enviando() =>
    loginControllerDeTeste(repository: _AuthRepositoryPendente())
      ..entrar(email: 'ana@bompreco.com.br', senha: 'Teste1234');

void main() {
  for (final MapEntry(key: tela, value: tamanho) in _telas.entries) {
    goldenTest(
      'Cenário: Dado o login web em $tela, então o formulário segue a largura e a marca',
      fileName: 'login_screen_web_$tela',
      // O spinner do "enviando" gira para sempre: pumpAndSettle não termina, e
      // no primeiro quadro o arco ainda não aparece.
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
                constraints: BoxConstraints.tight(tamanho),
                child: MediaQuery(
                  data: MediaQueryData(size: tamanho),
                  child: montarLogin(marca: marca, controller: controller()),
                ),
              ),
        ],
      ),
    );
  }
}
