import 'package:flutter/material.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/home/models/resumo_painel.dart';

enum SecaoPainel {
  inicio('Início', Icons.home_outlined, Icons.home),

  filiais('Filiais', Icons.storefront_outlined, Icons.storefront),

  panfletos('Panfletos', Icons.photo_library_outlined, Icons.photo_library),

  produtos('Produtos', Icons.sell_outlined, Icons.sell),

  pagina('Página', Icons.web_outlined, Icons.web);

  const SecaoPainel(this.titulo, this.icone, this.iconeSelecionado);

  final String titulo;

  final IconData icone;

  final IconData iconeSelecionado;
}

sealed class ResumoEstado {
  const ResumoEstado();
}

final class ResumoCarregando extends ResumoEstado {
  const ResumoCarregando();
}

final class ResumoCarregado extends ResumoEstado {
  const ResumoCarregado(this.resumo);

  final ResumoPainel resumo;
}

final class ResumoComFalha extends ResumoEstado {
  const ResumoComFalha(this.falha);

  final Falha falha;
}
