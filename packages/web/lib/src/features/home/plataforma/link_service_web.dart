import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum ResultadoCompartilhar { compartilhado, copiado }

/// Abrir, copiar e compartilhar o link da página pública (D16).
class LinkServiceWeb {
  LinkServiceWeb({
    Future<bool> Function(Uri url)? abrirUrl,
    Future<ShareResult> Function(ShareParams params)? compartilharNoSistema,
  }) : _abrirUrl =
           abrirUrl ?? ((url) => launchUrl(url, webOnlyWindowName: '_blank')),
       _compartilhar = compartilharNoSistema ?? SharePlus.instance.share;

  final Future<bool> Function(Uri url) _abrirUrl;

  final Future<ShareResult> Function(ShareParams params) _compartilhar;

  Future<bool> abrir(String url) async {
    try {
      return await _abrirUrl(Uri.parse(url));
    } on Exception {
      return false;
    }
  }

  Future<void> copiar(String url) =>
      Clipboard.setData(ClipboardData(text: url));

  /// Web: o compartilhar do navegador (Web Share API) com o texto. Sem
  /// suporte no navegador, copia o link (D16).
  ///
  /// No `share_plus` 13 (web), "indisponível" não vem no resultado (ele
  /// devolve `ShareResult.unavailable` até quando compartilha): sem
  /// `navigator.share`/`canShare`, ou com falha, ele cai no *fallback*; com
  /// `mailToFallbackEnabled: false` esse *fallback* lança `Exception`. É essa
  /// exceção que vira "copiar".
  Future<ResultadoCompartilhar> compartilhar(String texto, String url) async {
    try {
      await _compartilhar(
        ShareParams(text: texto, mailToFallbackEnabled: false),
      );
      return ResultadoCompartilhar.compartilhado;
    } on Object {
      await copiar(url);
      return ResultadoCompartilhar.copiado;
    }
  }
}
