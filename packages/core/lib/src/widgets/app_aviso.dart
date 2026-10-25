import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_cores.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';

enum TipoAviso {
  sucesso('Tudo certo!', Icons.check_circle_outline),

  erro('Ops, algo deu errado', Icons.error_outline),

  alerta('Atenção', Icons.warning_amber_outlined),

  info('Para sua informação', Icons.info_outline);

  const TipoAviso(this.tituloPadrao, this.icone);

  final String tituloPadrao;

  final IconData icone;

  Color cor(ColorScheme cores) => switch (this) {
    sucesso => AppCores.sucesso,
    erro => cores.error,
    alerta => AppCores.alerta,
    info => AppCores.info,
  };
}

class AppAviso extends StatelessWidget {
  const AppAviso({
    super.key,
    required this.mensagem,
    this.tipo = TipoAviso.sucesso,
    this.titulo,
    this.icone,
  });

  final String mensagem;
  final TipoAviso tipo;
  final String? titulo;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = tipo.cor(tema.colorScheme);
    return Row(
      children: [
        Icon(icone ?? tipo.icone, color: cor, size: AppIcones.padrao),
        const SizedBox(width: AppEspacamentos.md),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo ?? tipo.tituloPadrao,
                style: tema.textTheme.titleSmall?.copyWith(
                  color: tema.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppEspacamentos.xs),
              Text(
                mensagem,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
