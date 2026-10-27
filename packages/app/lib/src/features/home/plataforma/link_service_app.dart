import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum ResultadoCompartilhar { compartilhado, copiado }

/// Abrir, copiar e compartilhar o link da página pública (D16).
class LinkServiceApp {
  LinkServiceApp({
    Future<bool> Function(Uri url)? abrirUrl,
    Future<ShareResult> Function(ShareParams params)? compartilharNoSistema,
  }) : _abrirUrl =
           abrirUrl ??
           ((url) => launchUrl(url, mode: LaunchMode.externalApplication)),
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

  /// App: a folha de compartilhar do sistema com o texto (que leva o link).
  Future<ResultadoCompartilhar> compartilhar(String texto, String url) async {
    await _compartilhar(ShareParams(text: texto));
    return ResultadoCompartilhar.compartilhado;
  }
}
