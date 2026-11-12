import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: período dos acessos', () {
    test('Cenário: Dado nenhum filtro, então o padrão é 30 dias', () {
      expect(PeriodoAcessos.padrao, const PeriodoPredefinido(30));
      expect(PeriodoAcessos.padrao.toQuery(), {'periodo': 30});
    });

    test('Cenário: Dado um período personalizado, quando monto a query, então mando início e fim em ISO, sem periodo', () {
      final periodo = PeriodoPersonalizado(
        DateTime(2026, 1, 5),
        DateTime(2026, 2, 3),
      );

      expect(periodo.toQuery(), {'inicio': '2026-01-05', 'fim': '2026-02-03'});
    });

    for (final (inicio, fim, dias) in [
      (DateTime(2026, 11, 9), DateTime(2026, 11, 9), 1),
      (DateTime(2026, 10, 11), DateTime(2026, 11, 9), 30),
      (DateTime(2025, 11, 10), DateTime(2026, 11, 10), 366),
      (DateTime(2026, 2, 20), DateTime(2026, 3, 10), 19),
    ]) {
      test(
        'Cenário: Dado de ${DataDia.iso(inicio)} a ${DataDia.iso(fim)}, então o período tem $dias dias',
        () {
          expect(PeriodoPersonalizado(inicio, fim).dias, dias);
        },
      );
    }

    test(
      'Cenário: Dado dois períodos com os mesmos valores, então são iguais',
      () {
        expect(const PeriodoPredefinido(7), const PeriodoPredefinido(7));
        expect(
          PeriodoPersonalizado(DateTime(2026, 1, 1), DateTime(2026, 1, 2)),
          PeriodoPersonalizado(DateTime(2026, 1, 1), DateTime(2026, 1, 2)),
        );
        expect(
          const PeriodoPredefinido(7),
          isNot(const PeriodoPredefinido(15)),
        );
      },
    );
  });
}
