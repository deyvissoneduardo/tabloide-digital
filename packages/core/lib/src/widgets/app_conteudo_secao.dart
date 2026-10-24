import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/home/home_estado.dart';
import 'package:tabloide_core/src/widgets/estado_vazio.dart';

class AppConteudoSecao extends StatelessWidget {
  const AppConteudoSecao({super.key, required this.secao});

  final SecaoPainel secao;

  @override
  Widget build(BuildContext context) => EstadoVazio(
    icone: secao.iconeSelecionado,
    titulo: secao.titulo,
    mensagem: 'Em breve',
  );
}
