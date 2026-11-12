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

  static const larguraPrevia = 420.0;

  static const ladoLogoPrevia = 64.0;

  static const larguraCartaoProdutoPrevia = 156.0;

  static const colunasGradePrevia = 2;

  static const proporcaoFotoBanner = 16 / 9;

  static const larguraCartaoProdutoEditor = 140.0;

  static const alturaCarrosselEditor = 168.0;

  static const ladoQrCode = 160.0;

  static const alturaGrafico = 200.0;

  static const alturaGraficoBarras = 140.0;
}
