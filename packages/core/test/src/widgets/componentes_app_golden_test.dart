import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

class _ComponentesApp extends StatefulWidget {
  const _ComponentesApp();

  @override
  State<_ComponentesApp> createState() => _ComponentesAppState();
}

class _ComponentesAppState extends State<_ComponentesApp> {
  final _email = TextEditingController(text: 'ana@bompreco.com.br');
  final _senha = TextEditingController(text: 'Teste1234');
  final _vazio = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _vazio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    children: [
      const AppMarcaDestaque(),
      const SizedBox(height: AppEspacamentos.md),
      const AppMarcaCabecalho(),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoTexto(
        controller: _email,
        rotulo: 'E-mail',
        icone: Icons.email_outlined,
      ),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoTexto(
        controller: _vazio,
        rotulo: 'WhatsApp (com DDD)',
        icone: Icons.phone_outlined,
        erro: 'Informe um WhatsApp válido com DDD.',
      ),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoSenha(controller: _senha, rotulo: 'Senha'),
      const SizedBox(height: AppEspacamentos.md),
      AppCampoSelecao<FusoHorario>(
        valor: FusoHorario.saoPaulo,
        opcoes: FusoHorario.values,
        rotuloDe: (fuso) => fuso.rotulo,
        rotulo: 'Fuso horário',
        icone: Icons.schedule_outlined,
        aoMudar: (_) {},
      ),
      const SizedBox(height: AppEspacamentos.md),
      AppCartaoFilial(filial: filialFake, emUso: true, aoEscolherAcao: (_) {}),
      AppCartaoFilial(filial: filialFakeBairro, aoEscolherAcao: (_) {}),
      const SizedBox(height: AppEspacamentos.lg),
      AppBotaoPrincipal(rotulo: 'Entrar', aoPressionar: () {}),
      const SizedBox(height: AppEspacamentos.sm),
      const AppBotaoPrincipal(
        rotulo: 'Entrar',
        carregando: true,
        aoPressionar: null,
      ),
      Align(
        alignment: Alignment.centerRight,
        child: AppBotaoTexto(rotulo: 'Cadastre-se', aoPressionar: () {}),
      ),
    ],
  );
}

void main() {
  goldenTest(
    'Cenário: Dado o tema claro, então os componentes App* do core seguem o tema',
    fileName: 'componentes_app',
    pumpBeforeTest: (tester) async {
      await precarregarLogo(tester);
      await pumpNTimes(2, const Duration(milliseconds: 300))(tester);
    },
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Tema claro',
          constraints: const BoxConstraints.tightFor(width: 360, height: 1000),
          child: montarComMarca(
            const SizedBox.expand(child: _ComponentesApp()),
          ),
        ),
      ],
    ),
  );
}
