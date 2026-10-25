import 'package:flutter/material.dart';
import 'package:tabloide_core/src/responses/filial_response.dart';

enum AcaoFilial { usar, editar, excluir }

class AppCartaoFilial extends StatelessWidget {
  const AppCartaoFilial({
    super.key,
    required this.filial,
    this.emUso = false,
    this.aoTocar,
    this.aoEscolherAcao,
    this.podeExcluir = true,
  });

  final FilialResponse filial;
  final bool emUso;
  final VoidCallback? aoTocar;
  final ValueChanged<AcaoFilial>? aoEscolherAcao;
  final bool podeExcluir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final endereco = filial.endereco;
    final aoEscolherAcao = this.aoEscolherAcao;
    return Card(
      child: ListTile(
        onTap: aoTocar,
        leading: Icon(
          emUso ? Icons.storefront : Icons.storefront_outlined,
          color: tema.colorScheme.primary,
        ),
        title: Text(filial.nome),
        subtitle: Text(
          '${endereco.logradouro}, ${endereco.numero} · '
          '${endereco.bairro}, ${endereco.cidade}/${endereco.uf}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emUso) const Chip(label: Text('Em uso')),
            if (aoEscolherAcao != null)
              PopupMenuButton<AcaoFilial>(
                tooltip: 'Ações da filial ${filial.nome}',
                onSelected: aoEscolherAcao,
                itemBuilder: (_) => [
                  if (!emUso)
                    const PopupMenuItem(
                      value: AcaoFilial.usar,
                      child: Text('Usar esta filial'),
                    ),
                  const PopupMenuItem(
                    value: AcaoFilial.editar,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: AcaoFilial.excluir,
                    enabled: podeExcluir,
                    child: Text(
                      podeExcluir
                          ? 'Excluir'
                          : 'Excluir (mantenha ao menos uma filial)',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
