import 'package:dio/dio.dart';
import 'package:dio/io.dart';

Dio criarDio(BaseOptions opcoes) => DioForNative(opcoes);
