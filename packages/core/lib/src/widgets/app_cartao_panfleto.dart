import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/panfletos/models/tipo_arquivo_panfleto.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

enum AcaoPanfleto { editar, excluir }

class AppCartaoPanfleto extends StatelessWidget {
  const AppCartaoPanfleto({
    super.key,
    required this.panfleto,
    this.aoTocar,
    this.aoEscolherAcao,
  });

  final PanfletoResponse panfleto;
  final VoidCallback? aoTocar;
  final ValueChanged<AcaoPanfleto>? aoEscolherAcao;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final vigencia = panfleto.vigencia;
    final inicio = DataDia.completa(vigencia.dataInicio);
    final aoEscolherAcao = this.aoEscolherAcao;
    return Card(
      child: ListTile(
        onTap: aoTocar,
        leading: ClipRRect(
          borderRadius: AppRaios.bordaSm,
          child: switch (panfleto.tipo) {
            TipoArquivoPanfleto.pdf => Icon(
              Icons.picture_as_pdf_outlined,
              size: AppIcones.destaque,
              color: cores.primary,
              semanticLabel:
                  'Panfleto em PDF ${vigencia.situacao.rotulo.toLowerCase()} de $inicio',
            ),
            TipoArquivoPanfleto.imagem => Image.network(
              panfleto.urlArquivo,
              width: AppIcones.destaque,
              height: AppIcones.destaque,
              fit: BoxFit.cover,
              semanticLabel:
                  'Panfleto ${vigencia.situacao.rotulo.toLowerCase()} de $inicio',
              errorBuilder: (_, _, _) => Icon(
                Icons.broken_image_outlined,
                size: AppIcones.destaque,
                color: cores.onSurfaceVariant,
              ),
            ),
          },
        ),
        title: Text(switch (vigencia.situacao) {
          SituacaoVigencia.vigente => 'Vigente desde $inicio',
          SituacaoVigencia.agendado => 'Agendado para $inicio',
        }),
        subtitle: Text(switch (vigencia.dataLimite) {
          final limite? => 'Válido até ${DataDia.curta(limite)}',
          null => 'Sem data limite',
        }),
        trailing: aoEscolherAcao == null
            ? null
            : PopupMenuButton<AcaoPanfleto>(
                tooltip: 'Ações do panfleto de $inicio',
                onSelected: aoEscolherAcao,
                itemBuilder: (_) => [
                  if (vigencia.editavel)
                    const PopupMenuItem(
                      value: AcaoPanfleto.editar,
                      child: Text('Editar'),
                    ),
                  const PopupMenuItem(
                    value: AcaoPanfleto.excluir,
                    child: Text('Excluir'),
                  ),
                ],
              ),
      ),
    );
  }
}
