import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/widgets/app_logo_identidade.dart';

/// Cabeçalho da prévia da página: logo e nome do lojista (sem rodapé).
class AppPreviaCabecalho extends StatelessWidget {
  const AppPreviaCabecalho({super.key, required this.identidade});

  final IdentidadeResponse identidade;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppEspacamentos.md),
      child: Row(
        children: [
          AppLogoIdentidade(
            url: identidade.urlLogo,
            nome: identidade.nomeFantasia,
            tamanho: AppIcones.destaque,
          ),
          const SizedBox(width: AppEspacamentos.md),
          Expanded(
            child: Text(
              identidade.nomeFantasia,
              style: tema.textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
