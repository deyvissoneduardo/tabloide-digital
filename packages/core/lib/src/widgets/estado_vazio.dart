import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';

/// Tela ou seção sem conteúdo: ícone, título, mensagem e ação opcional.
class EstadoVazio extends StatelessWidget {
  /// Cria o estado vazio.
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
    this.rotuloAcao,
    this.aoAgir,
  }) : assert(
         (rotuloAcao == null) == (aoAgir == null),
         'rotuloAcao e aoAgir vêm juntos',
       );

  /// Ícone ilustrativo, na cor primária.
  final IconData icone;

  /// O que está vazio (ex.: "Nenhuma filial cadastrada").
  final String titulo;

  /// Orientação para o lojista sair do vazio.
  final String? mensagem;

  /// Texto do botão (ex.: "Cadastrar filial").
  final String? rotuloAcao;

  /// Ação do botão.
  final VoidCallback? aoAgir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return _Centralizado(
      children: [
        Icon(icone, size: AppIcones.destaque, color: tema.colorScheme.primary),
        const SizedBox(height: AppEspacamentos.md),
        Text(
          titulo,
          style: tema.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (mensagem case final mensagem?) ...[
          const SizedBox(height: AppEspacamentos.sm),
          Text(
            mensagem,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (aoAgir case final aoAgir?) ...[
          const SizedBox(height: AppEspacamentos.lg),
          FilledButton(onPressed: aoAgir, child: Text(rotuloAcao!)),
        ],
      ],
    );
  }
}

/// Falha ao carregar: ícone de erro, mensagem e "Tentar de novo".
class EstadoFalha extends StatelessWidget {
  /// Cria o estado de falha.
  const EstadoFalha({
    super.key,
    required this.mensagem,
    required this.aoTentarDeNovo,
    this.icone = Icons.cloud_off,
  });

  /// Mensagem da `Falha`, já em linguagem do lojista.
  final String mensagem;

  /// Refaz a operação que falhou.
  final VoidCallback aoTentarDeNovo;

  /// Ícone ilustrativo, na cor de erro.
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return _Centralizado(
      children: [
        Icon(icone, size: AppIcones.destaque, color: tema.colorScheme.error),
        const SizedBox(height: AppEspacamentos.md),
        Text(
          mensagem,
          style: tema.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppEspacamentos.lg),
        FilledButton(
          onPressed: aoTentarDeNovo,
          child: const Text('Tentar de novo'),
        ),
      ],
    );
  }
}

class _Centralizado extends StatelessWidget {
  const _Centralizado({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppEspacamentos.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppLayout.larguraMaximaFormulario,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    ),
  );
}
