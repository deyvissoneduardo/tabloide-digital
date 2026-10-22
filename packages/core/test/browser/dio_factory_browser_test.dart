@TestOn('browser')
@Tags(['browser'])
library;

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/src/http/dio_factory.dart';

void main() {
  group('Funcionalidade: escolha do Dio pela plataforma', () {
    test('Cenário: Dado o navegador (web), quando crio o Dio, então ele é DioForBrowser', () {
      expect(
        criarDio(BaseOptions(baseUrl: 'http://api')),
        isA<DioForBrowser>(),
      );
    });
  });
}
