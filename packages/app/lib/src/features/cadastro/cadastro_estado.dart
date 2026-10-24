import 'package:tabloide_core/tabloide_core.dart';

sealed class CadastroEstado {
  const CadastroEstado();
}

final class CadastroOcioso extends CadastroEstado {
  const CadastroOcioso();
}

final class CadastroEnviando extends CadastroEstado {
  const CadastroEnviando();
}

final class CadastroComFalha extends CadastroEstado {
  const CadastroComFalha(this.falha);

  final Falha falha;
}

final class CadastroConcluido extends CadastroEstado {
  const CadastroConcluido(this.conta);

  final CadastroResponse conta;
}
