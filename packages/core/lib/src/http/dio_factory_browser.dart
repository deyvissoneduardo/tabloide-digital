import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Dio da web, com `XMLHttpRequest` do navegador.
Dio criarDio(BaseOptions opcoes) => DioForBrowser(opcoes);
