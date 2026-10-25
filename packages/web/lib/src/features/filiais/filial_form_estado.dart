import 'package:tabloide_core/tabloide_core.dart';

sealed class FilialFormEstado {
  const FilialFormEstado();
}

final class FilialFormOcioso extends FilialFormEstado {
  const FilialFormOcioso();
}

final class FilialFormEnviando extends FilialFormEstado {
  const FilialFormEnviando();
}

final class FilialFormComFalha extends FilialFormEstado {
  const FilialFormComFalha(this.falha);

  final Falha falha;
}

final class FilialFormConcluido extends FilialFormEstado {
  const FilialFormConcluido(this.filial);

  final FilialResponse filial;
}
