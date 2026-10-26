import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/produtos/models/centavos.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';
import 'package:tabloide_core/src/responses/produto_response.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

enum AcaoProduto { editar, excluir }

class AppCartaoProduto extends StatelessWidget {
  const AppCartaoProduto({
    super.key,
    required this.produto,
    this.aoTocar,
    this.aoEscolherAcao,
  });

  final ProdutoResponse produto;
  final VoidCallback? aoTocar;
  final ValueChanged<AcaoProduto>? aoEscolherAcao;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final vigencia = produto.vigencia;
    final promocional = Centavos.formatar(produto.precoPromocionalCentavos);
    final quantidade = produto.quantidade;
    final urlFoto = produto.urlFoto;
    final semFoto = Icon(
      Icons.sell_outlined,
      size: AppIcones.destaque,
      color: cores.onSurfaceVariant,
    );
    final aoEscolherAcao = this.aoEscolherAcao;
    return Card(
      child: ListTile(
        onTap: aoTocar,
        isThreeLine: true,
        leading: ClipRRect(
          borderRadius: AppRaios.bordaSm,
          child: urlFoto == null
              ? semFoto
              : Image.network(
                  urlFoto,
                  width: AppIcones.destaque,
                  height: AppIcones.destaque,
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto de ${produto.nome}',
                  errorBuilder: (_, _, _) => semFoto,
                ),
        ),
        title: Text(
          quantidade == null ? produto.nome : '${produto.nome} · $quantidade',
        ),
        subtitle: Text(
          '${switch (produto.precoOriginalCentavos) {
            final original? => 'de ${Centavos.formatar(original)} por $promocional',
            null => promocional,
          }}\n'
          '${switch (vigencia.situacao) {
            SituacaoVigencia.vigente => 'Vigente',
            SituacaoVigencia.agendado => 'Agendado para ${DataDia.completa(vigencia.dataInicio)}',
          }} · ${switch (vigencia.dataLimite) {
            final limite? => 'válido até ${DataDia.curta(limite)}',
            null => 'sem data limite',
          }}',
        ),
        trailing: aoEscolherAcao == null
            ? null
            : PopupMenuButton<AcaoProduto>(
                tooltip: 'Ações do produto ${produto.nome}',
                onSelected: aoEscolherAcao,
                itemBuilder: (_) => [
                  if (vigencia.editavel)
                    const PopupMenuItem(
                      value: AcaoProduto.editar,
                      child: Text('Editar'),
                    ),
                  const PopupMenuItem(
                    value: AcaoProduto.excluir,
                    child: Text('Excluir'),
                  ),
                ],
              ),
      ),
    );
  }
}
