import 'package:flutter/material.dart';
import 'package:tabloide_core/src/theme/app_icones.dart';
import 'package:tabloide_core/src/theme/app_raios.dart';

class AppBotaoPrincipal extends StatelessWidget {
  const AppBotaoPrincipal({
    super.key,
    required this.rotulo,
    required this.aoPressionar,
    this.carregando = false,
    this.rotuloCarregando,
  });

  final String rotulo;
  final VoidCallback? aoPressionar;
  final bool carregando;
  final String? rotuloCarregando;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: cores.primary,
        shape: const RoundedRectangleBorder(borderRadius: AppRaios.bordaMd),
      ),
      onPressed: carregando ? null : aoPressionar,
      child: carregando
          ? SizedBox.square(
              dimension: AppIcones.padrao,
              child: CircularProgressIndicator(
                semanticsLabel: rotuloCarregando ?? rotulo,
                color: cores.secondary,
              ),
            )
          : Text(
              rotulo,
              style: tema.textTheme.titleMedium?.copyWith(
                color: cores.onPrimary,
              ),
            ),
    );
  }
}
