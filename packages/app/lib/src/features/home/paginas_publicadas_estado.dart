import 'package:tabloide_app/src/features/home/contexto_paginas.dart';
import 'package:tabloide_core/tabloide_core.dart';

sealed class PaginasPublicadasEstado {
  const PaginasPublicadasEstado();
}

final class PaginasCarregando extends PaginasPublicadasEstado {
  const PaginasCarregando();
}

final class PaginasCarregadas extends PaginasPublicadasEstado {
  const PaginasCarregadas(this.contexto);

  final ContextoPaginas contexto;
}

final class PaginasComFalha extends PaginasPublicadasEstado {
  const PaginasComFalha(this.falha);

  final Falha falha;
}
