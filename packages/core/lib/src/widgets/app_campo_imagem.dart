import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

class AppCampoImagem extends StatelessWidget {
  const AppCampoImagem({
    super.key,
    required this.rotulo,
    required this.descricao,
    this.bytes,
    this.url,
    this.aoEscolher,
    this.aoRemover,
    this.carregando = false,
    this.erro,
    this.ajuda,
    this.proporcao = 3 / 4,
  });

  final String rotulo;
  final String descricao;
  final Uint8List? bytes;
  final String? url;
  final VoidCallback? aoEscolher;
  final VoidCallback? aoRemover;
  final bool carregando;
  final String? erro;
  final String? ajuda;
  final double proporcao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final temImagem = bytes != null || url != null;
    final quebrada = Icon(
      Icons.broken_image_outlined,
      size: AppIcones.destaque,
      color: cores.onSurfaceVariant,
    );
    final erro = this.erro;
    final ajuda = this.ajuda;
    final aoRemover = this.aoRemover;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(rotulo, style: tema.textTheme.titleSmall),
        const SizedBox(height: AppEspacamentos.sm),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: AppLayout.alturaPreviaImagem,
            ),
            child: AspectRatio(
              aspectRatio: proporcao,
              child: Semantics(
                label: temImagem ? descricao : 'Nenhuma imagem escolhida',
                image: true,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cores.surfaceContainerHighest,
                    borderRadius: AppRaios.bordaMd,
                    border: Border.all(
                      color: erro == null ? cores.outlineVariant : cores.error,
                    ),
                  ),
                  child: switch ((bytes, url)) {
                    (final bytes?, _) => Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) => quebrada,
                    ),
                    (null, final url?) => Image.network(
                      url,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) => quebrada,
                    ),
                    (null, null) => Icon(
                      Icons.add_photo_alternate_outlined,
                      size: AppIcones.destaque,
                      color: cores.onSurfaceVariant,
                    ),
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppEspacamentos.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppEspacamentos.sm,
          children: [
            OutlinedButton.icon(
              onPressed: carregando ? null : aoEscolher,
              icon: carregando
                  ? const SizedBox.square(
                      dimension: AppIcones.pequeno,
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Enviando imagem',
                      ),
                    )
                  : const Icon(Icons.upload_outlined),
              label: Text(
                carregando
                    ? 'Enviando imagem'
                    : temImagem
                    ? 'Trocar imagem'
                    : 'Escolher imagem',
              ),
            ),
            if (temImagem && aoRemover != null)
              TextButton.icon(
                onPressed: carregando ? null : aoRemover,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover imagem'),
              ),
          ],
        ),
        if (erro != null) ...[
          const SizedBox(height: AppEspacamentos.xs),
          Text(
            erro,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodySmall?.copyWith(color: cores.error),
          ),
        ],
        if (ajuda != null) ...[
          const SizedBox(height: AppEspacamentos.xs),
          Text(
            ajuda,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodySmall?.copyWith(
              color: cores.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
