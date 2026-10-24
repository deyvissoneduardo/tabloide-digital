import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

Dio criarDio(BaseOptions opcoes) => DioForBrowser(opcoes);
