import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum ResultadoCompartilhar { compartilhado, copiado }

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
