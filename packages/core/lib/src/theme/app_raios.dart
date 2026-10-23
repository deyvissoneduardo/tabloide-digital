import 'package:flutter/painting.dart';

/// Raios de borda do painel (forma "suave e plana").
abstract final class AppRaios {
  /// 8: chips e elementos pequenos.
  static const sm = 8.0;

  /// 12: cards, campos de texto e blocos de skeleton.
  static const md = 12.0;

  /// 16: dialogs e bottom sheets.
  static const lg = 16.0;

  /// Pílula: botões.
  static const pilula = 999.0;

  /// `BorderRadius` de [sm].
  static const bordaSm = BorderRadius.all(Radius.circular(sm));

  /// `BorderRadius` de [md].
  static const bordaMd = BorderRadius.all(Radius.circular(md));

  /// `BorderRadius` de [lg].
  static const bordaLg = BorderRadius.all(Radius.circular(lg));

  /// `BorderRadius` de [pilula].
  static const bordaPilula = BorderRadius.all(Radius.circular(pilula));
}
