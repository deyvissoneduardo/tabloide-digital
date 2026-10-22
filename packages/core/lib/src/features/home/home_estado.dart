import 'package:flutter/material.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';

/// Seções do painel do lojista.
enum SecaoPainel {
  /// Visão geral.
  inicio('Início', Icons.home_outlined, Icons.home),

  /// Lojas físicas do lojista.
  filiais('Filiais', Icons.storefront_outlined, Icons.storefront),

  /// Panfletos por filial.
  panfletos('Panfletos', Icons.photo_library_outlined, Icons.photo_library),

  /// Produtos em oferta.
  produtos('Produtos', Icons.sell_outlined, Icons.sell);

  const SecaoPainel(this.titulo, this.icone, this.iconeSelecionado);

  /// Rótulo exibido na navegação.
  final String titulo;

  /// Ícone quando a seção não está selecionada.
  final IconData icone;

  /// Ícone quando a seção está selecionada.
  final IconData iconeSelecionado;
}

/// Estado do resumo da seção Início.
sealed class ResumoEstado {
  const ResumoEstado();
}

/// Buscando o resumo.
final class ResumoCarregando extends ResumoEstado {
  /// Cria o estado.
  const ResumoCarregando();
}

/// Resumo disponível.
final class ResumoCarregado extends ResumoEstado {
  /// Cria o estado com o [resumo].
  const ResumoCarregado(this.resumo);

  /// Dados exibidos.
  final ResumoPainel resumo;
}

/// A busca falhou.
final class ResumoComFalha extends ResumoEstado {
  /// Cria o estado com a [falha].
  const ResumoComFalha(this.falha);

  /// O que deu errado.
  final Falha falha;
}
