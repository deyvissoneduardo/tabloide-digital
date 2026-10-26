import 'package:flutter/widgets.dart';

enum ClasseTamanho {
  compacto,

  medio,

  expandido;

  static ClasseTamanho daLargura(double largura) => largura < AppLayout.medio
      ? compacto
      : largura < AppLayout.expandido
      ? medio
      : expandido;

  static ClasseTamanho de(BuildContext context) =>
      daLargura(MediaQuery.sizeOf(context).width);
}

abstract final class AppLayout {
  static const medio = 600.0;

  static const expandido = 840.0;

  static const larguraMaximaConteudo = 1200.0;

  static const larguraMaximaFormulario = 600.0;

  static const larguraMenuLateral = 220.0;

  static const alvoMinimo = 48.0;

  static const alturaPreviaImagem = 320.0;
}
