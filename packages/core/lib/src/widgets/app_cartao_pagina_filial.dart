import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_cores.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/widgets/app_aviso.dart';
import 'package:tabloide_core/src/widgets/esqueleto.dart';

/// O que a página pública da filial mostra agora (plano §4.8).
enum SituacaoPaginaFilial { panfleto, produtos, vazia }

/// Card da home com a página pública de uma filial: o que está no ar, link,
/// QR Code e ações (abrir, copiar, compartilhar). Aviso RN35 sem conta ativa.
class AppCartaoPaginaFilial extends StatelessWidget {
  const AppCartaoPaginaFilial({
    super.key,
    required this.nomeFilial,
    required this.urlPublica,
    required this.situacao,
    required this.produtosNoAr,
    required this.contaAtiva,
    required this.aoAbrir,
    required this.aoCopiar,
    required this.aoCompartilhar,
    this.qrCode,
    this.qrCodeFalhou = false,
  });

  final String nomeFilial;

  final String urlPublica;

  final SituacaoPaginaFilial situacao;

  final int produtosNoAr;

  final bool contaAtiva;

  /// PNG do QR Code; `null` = carregando.
  final Uint8List? qrCode;

  final bool qrCodeFalhou;

  final VoidCallback aoAbrir;

  final VoidCallback aoCopiar;

  final VoidCallback aoCompartilhar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final (icone, status, cor) = switch (situacao) {
      SituacaoPaginaFilial.panfleto => (
        Icons.photo_library_outlined,
        'No ar: panfleto',
        AppCores.sucesso,
      ),
      SituacaoPaginaFilial.produtos => (
        Icons.sell_outlined,
        produtosNoAr == 1
            ? 'No ar: 1 produto'
            : 'No ar: $produtosNoAr produtos',
        AppCores.sucesso,
      ),
      SituacaoPaginaFilial.vazia => (
        Icons.remove_circle_outline,
        'Nada no ar',
        cores.onSurfaceVariant,
      ),
    };
    final qrCode = this.qrCode;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppEspacamentos.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(nomeFilial, style: tema.textTheme.titleMedium),
            const SizedBox(height: AppEspacamentos.xs),
            Row(
              children: [
                Icon(icone, size: AppIcones.pequeno, color: cor),
                const SizedBox(width: AppEspacamentos.xs),
                Expanded(child: Text(status, style: tema.textTheme.bodyMedium)),
              ],
            ),
            if (!contaAtiva) ...[
              const SizedBox(height: AppEspacamentos.sm),
              const AppAviso(
                tipo: TipoAviso.alerta,
                mensagem: 'Sua página está fora do ar até a conta ser ativada.',
              ),
            ],
            const SizedBox(height: AppEspacamentos.sm),
            Text(
              urlPublica,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodySmall?.copyWith(
                color: cores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppEspacamentos.md),
            Center(
              child: SizedBox.square(
                dimension: AppLayout.ladoQrCode,
                child: switch ((qrCode, qrCodeFalhou)) {
                  (_, true) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: AppIcones.destaque,
                        color: cores.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppEspacamentos.xs),
                      Text(
                        'QR Code indisponível',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: cores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  (final png?, false) => Image.memory(
                    png,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    semanticLabel: 'QR Code da página da filial $nomeFilial',
                  ),
                  (null, false) => const Esqueleto(
                    altura: AppLayout.ladoQrCode,
                    largura: AppLayout.ladoQrCode,
                  ),
                },
              ),
            ),
            const SizedBox(height: AppEspacamentos.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppEspacamentos.sm,
              runSpacing: AppEspacamentos.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: aoAbrir,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir página'),
                ),
                OutlinedButton.icon(
                  onPressed: aoCopiar,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar link'),
                ),
                OutlinedButton.icon(
                  onPressed: aoCompartilhar,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Compartilhar link'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
