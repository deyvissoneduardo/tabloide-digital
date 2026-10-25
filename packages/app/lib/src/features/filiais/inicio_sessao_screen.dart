import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/src/features/filiais/escolher_filial_screen.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/filiais/filiais_estado.dart';
import 'package:tabloide_app/src/features/filiais/filial_form_screen.dart';
import 'package:tabloide_app/src/features/home/home_screen.dart';
import 'package:tabloide_app/src/features/login/login_screen.dart';
import 'package:tabloide_core/tabloide_core.dart';

class InicioSessaoScreen extends StatefulWidget {
  const InicioSessaoScreen({super.key});

  @override
  State<InicioSessaoScreen> createState() => _InicioSessaoScreenState();
}

class _InicioSessaoScreenState extends State<InicioSessaoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciar());
  }

  Future<void> _iniciar() async {
    final sessao = context.read<Sessao>();
    final filiais = context.read<FiliaisController>();
    final navegador = Navigator.of(context);
    if (await sessao.restaurar()) {
      await filiais.carregar();
      if (filiais.estado case FiliaisComFalha(
        falha: FalhaApi(codigo: 'NAO_AUTENTICADO'),
      )) {
        await sessao.encerrar();
      }
    }
    if (!mounted) return;
    if (sessao.ativa && filiais.estado is FiliaisComFalha) return;
    await navegador.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => !sessao.ativa
            ? const LoginScreen()
            : filiais.filiais.isEmpty
            ? const FilialFormScreen(obrigatoria: true)
            : filiais.emUso == null
            ? const EscolherFilialScreen()
            : const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<FiliaisController>().estado;
    return Scaffold(
      body: SafeArea(
        child: switch (estado) {
          FiliaisComFalha(:final falha) => EstadoFalha(
            mensagem: falha.mensagem,
            aoTentarDeNovo: _iniciar,
          ),
          _ => const EsqueletoLista(),
        },
      ),
    );
  }
}
