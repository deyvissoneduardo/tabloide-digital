import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

/// Bloco cinza no formato do conteúdo que ainda está carregando.
///
/// Padrão canônico de carregamento de listas e cards; ações (salvar,
/// excluir) usam spinner dentro do botão. É estático de propósito: sem
/// animação, os goldens ficam estáveis e o `pumpAndSettle` termina.
class Esqueleto extends StatelessWidget {
  /// Cria um bloco com [altura] e [largura] (padrão: toda a largura).
  const Esqueleto({super.key, required this.altura, this.largura});

  /// Altura do bloco.
  final double altura;

  /// Largura do bloco; `null` ocupa toda a largura disponível.
  final double? largura;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Carregando',
    child: Container(
      height: altura,
      width: largura ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRaios.bordaMd,
      ),
    ),
  );
}

/// Lista de [quantidade] esqueletos de [altura], no lugar de uma lista que
/// ainda está carregando.
class EsqueletoLista extends StatelessWidget {
  /// Cria a lista de esqueletos.
  const EsqueletoLista({super.key, this.quantidade = 3, this.altura = 72});

  /// Quantos itens simular.
  final int quantidade;

  /// Altura de cada item.
  final double altura;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: quantidade,
    separatorBuilder: (_, _) => const SizedBox(height: AppEspacamentos.sm),
    itemBuilder: (_, _) => Esqueleto(altura: altura),
  );
}
