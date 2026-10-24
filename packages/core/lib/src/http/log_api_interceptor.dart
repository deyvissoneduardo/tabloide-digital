import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final class LogApiInterceptor extends Interceptor {
  LogApiInterceptor({void Function(String linha)? escrever})
    : _escrever = escrever ?? debugPrint;

  final void Function(String linha) _escrever;

  static const _amarelo = '\x1B[33m';
  static const _vermelho = '\x1B[31m';
  static const _reset = '\x1B[0m';
  static const _inicio = 'logApiInicio';
  static const _ocultos = {'senha', 'password', 'token', 'authorization'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_inicio] = DateTime.now();
    _bloco(_amarelo, 'REQUEST', [
      '${options.method} ${options.uri}',
      if (options.headers.isNotEmpty) 'Headers: ${_json(options.headers)}',
      if (options.data != null) 'Body: ${_json(options.data)}',
    ]);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _resposta(response.requestOptions, response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _resposta(err.requestOptions, err.response, erro: err);
    handler.next(err);
  }

  void _resposta(
    RequestOptions options,
    Response<dynamic>? response, {
    DioException? erro,
  }) {
    final status = response?.statusCode;
    final falhou = response == null || (status ?? 0) >= 400;
    final inicio = options.extra[_inicio];
    final duracao = inicio is DateTime
        ? ' (${DateTime.now().difference(inicio).inMilliseconds} ms)'
        : '';
    _bloco(
      falhou ? _vermelho : _amarelo,
      'RESPONSE ${status ?? erro?.type.name ?? '?'}$duracao',
      [
        '${options.method} ${options.uri}',
        if (response == null && erro != null)
          'Erro: ${erro.message ?? erro.error}',
        if (response?.data != null) 'Body: ${_json(response!.data)}',
      ],
    );
  }

  void _bloco(String cor, String titulo, List<String> linhas) {
    final topo = '┌──────────── $titulo ';
    final corpo = [
      for (final linha in linhas)
        for (final parte in linha.split('\n')) '│ $parte',
    ];
    for (final linha in [topo.padRight(60, '─'), ...corpo, '└${'─' * 59}']) {
      _escrever('$cor$linha$_reset');
    }
  }

  String _json(Object? dados) {
    final limpo = _ocultar(dados);
    try {
      return const JsonEncoder.withIndent('  ').convert(limpo);
    } on Object {
      return '$limpo';
    }
  }

  Object? _ocultar(Object? dados) => switch (dados) {
    final Map<dynamic, dynamic> mapa => {
      for (final MapEntry(:key, :value) in mapa.entries)
        '$key': _ocultos.contains('$key'.toLowerCase())
            ? '***'
            : _ocultar(value),
    },
    final List<dynamic> lista => [for (final item in lista) _ocultar(item)],
    _ => dados,
  };
}
