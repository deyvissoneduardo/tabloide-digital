import 'package:dio/dio.dart';

/// Plataforma sem `dart:io` nem `dart:js_interop`.
Dio criarDio(BaseOptions opcoes) =>
    throw UnsupportedError('Plataforma sem implementação de Dio.');
