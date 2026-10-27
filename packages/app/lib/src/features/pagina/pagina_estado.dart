import 'package:tabloide_core/tabloide_core.dart';

sealed class PaginaEstado {
  const PaginaEstado();
}

final class PaginaCarregando extends PaginaEstado {
  const PaginaCarregando();
}

final class PaginaCarregada extends PaginaEstado {
  const PaginaCarregada(this.dados);

  final DadosPagina dados;
}

final class PaginaComFalha extends PaginaEstado {
  const PaginaComFalha(this.falha);

  final Falha falha;
}
