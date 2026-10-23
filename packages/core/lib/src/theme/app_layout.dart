import 'package:flutter/widgets.dart';

/// Classe de tamanho da janela (Material 3), do celular para cima.
enum ClasseTamanho {
  /// Largura menor que [AppLayout.medio]: celular.
  compacto,

  /// De [AppLayout.medio] até antes de [AppLayout.expandido]: tablet em pé.
  medio,

  /// A partir de [AppLayout.expandido]: tablet deitado e desktop.
  expandido;

  /// Classe da [largura] informada.
  static ClasseTamanho daLargura(double largura) => largura < AppLayout.medio
      ? compacto
      : largura < AppLayout.expandido
      ? medio
      : expandido;

  /// Classe da janela atual.
  static ClasseTamanho de(BuildContext context) =>
      daLargura(MediaQuery.sizeOf(context).width);
}

/// Breakpoints e larguras de layout. Mobile first: o layout base é o
/// compacto e os outros só acrescentam.
abstract final class AppLayout {
  /// Início da classe média.
  static const medio = 600.0;

  /// Início da classe expandida.
  static const expandido = 840.0;

  /// Largura máxima do conteúdo, centralizado em telas largas.
  static const larguraMaximaConteudo = 1200.0;

  /// Largura máxima de formulários, para as linhas não ficarem longas demais.
  static const larguraMaximaFormulario = 600.0;

  /// Largura do menu lateral estendido.
  static const larguraMenuLateral = 220.0;

  /// Altura mínima de alvo de toque (acessibilidade).
  static const alvoMinimo = 48.0;
}
