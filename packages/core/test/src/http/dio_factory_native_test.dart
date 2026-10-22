@TestOn('vm')
library;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/src/http/dio_factory.dart';

void main() {
  group('Funcionalidade: escolha do Dio pela plataforma', () {
    test('Cenário: Dado a VM (app), quando crio o Dio, então ele é DioForNative com a URL base', () {
      final dio = criarDio(BaseOptions(baseUrl: 'http://api'));

      expect(dio, isA<DioForNative>());
      expect(dio.options.baseUrl, 'http://api');
    });
  });
}
