import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Placeholder da seção até as features existirem.
class ConteudoSecao extends StatelessWidget {
  const ConteudoSecao({super.key, required this.secao});

  final SecaoPainel secao;

  @override
  Widget build(BuildContext context) => EstadoVazio(
    icone: secao.iconeSelecionado,
    titulo: secao.titulo,
    mensagem: 'Em breve',
  );
}
