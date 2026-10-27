import 'package:flutter/painting.dart';

abstract final class AppRaios {
  static const sm = 8.0;

  static const md = 12.0;

  static const lg = 16.0;

  /// Base do cabeçalho da prévia da página (igual à página pública).
  static const xl = 24.0;

  static const pilula = 999.0;

  static const bordaSm = BorderRadius.all(Radius.circular(sm));

  static const bordaMd = BorderRadius.all(Radius.circular(md));

  static const bordaLg = BorderRadius.all(Radius.circular(lg));

  static const bordaPilula = BorderRadius.all(Radius.circular(pilula));
}
