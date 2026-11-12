import 'package:tabloide_core/src/features/acessos/models/periodo_acessos.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';

extension PeriodoAcessosQuery on PeriodoAcessos {
  Map<String, Object> toQuery() => switch (this) {
    PeriodoPredefinido(:final dias) => {'periodo': dias},
    PeriodoPersonalizado(:final inicio, :final fim) => {
      'inicio': DataDia.iso(inicio),
      'fim': DataDia.iso(fim),
    },
  };
}
