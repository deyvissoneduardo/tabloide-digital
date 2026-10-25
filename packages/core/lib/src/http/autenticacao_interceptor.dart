import 'package:dio/dio.dart';

final class AutenticacaoInterceptor extends Interceptor {
  AutenticacaoInterceptor(this._token);

  final String? Function() _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token() case final token?) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
