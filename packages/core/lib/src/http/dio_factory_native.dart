import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Dio do app (Android/iOS/desktop), com `HttpClient` do `dart:io`.
Dio criarDio(BaseOptions opcoes) => DioForNative(opcoes);
