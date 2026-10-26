import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/categoria_response.dart';

enum AcaoCategoria { renomear, excluir }

String _contagem(int quantidade, String singular, String plural) =>
    '$quantidade ${quantidade == 1 ? singular : plural}';

class AppCartaoCategoria extends StatelessWidget {
  const AppCartaoCategoria({
    super.key,
    required this.categoria,
    this.aoTocar,
    this.aoEscolherAcao,
  });

  final CategoriaResponse categoria;
  final VoidCallback? aoTocar;
  final ValueChanged<AcaoCategoria>? aoEscolherAcao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final produtos = categoria.produtos;
    final partes = [
      if (produtos.vigentes > 0)
        _contagem(produtos.vigentes, 'vigente', 'vigentes'),
      if (produtos.agendados > 0)
        _contagem(produtos.agendados, 'agendado', 'agendados'),
      if (produtos.vencidos > 0)
        _contagem(produtos.vencidos, 'vencido', 'vencidos'),
    ];
    final aoEscolherAcao = this.aoEscolherAcao;
    return Card(
      child: ListTile(
        onTap: aoTocar,
        leading: Icon(Icons.category_outlined, color: tema.colorScheme.primary),
        title: Text(categoria.nome),
        subtitle: Text(partes.isEmpty ? 'Nenhum produto' : partes.join(' · ')),
        trailing: aoEscolherAcao == null
            ? null
            : PopupMenuButton<AcaoCategoria>(
                tooltip: 'Ações da categoria ${categoria.nome}',
                onSelected: aoEscolherAcao,
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: AcaoCategoria.renomear,
                    child: Text('Renomear'),
                  ),
                  PopupMenuItem(
                    value: AcaoCategoria.excluir,
                    enabled: categoria.podeExcluir,
                    child: Text(
                      categoria.podeExcluir ? 'Excluir' : 'Excluir (exclua antes os produtos vigentes e agendados)',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
