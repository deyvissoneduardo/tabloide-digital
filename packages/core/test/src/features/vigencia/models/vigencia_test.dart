import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

Vigencia _vigencia(SituacaoVigencia situacao, {bool editavel = true}) =>
    Vigencia(
      dataInicio: DateTime(2026, 10, 18),
      situacao: situacao,
      editavel: editavel,
    );

void main() {
  group('Funcionalidade: vigência de itens (panfleto e produto)', () {
    test('Cenário: Dado um item agendado e editável, então a data de início pode mudar', () {
      expect(_vigencia(SituacaoVigencia.agendado).podeAlterarInicio, isTrue);
    });

    test('Cenário: Dado um item já vigente, então a data de início fica travada (RN26)', () {
      expect(_vigencia(SituacaoVigencia.vigente).podeAlterarInicio, isFalse);
    });

    test(
      'Cenário: Dado um item não editável, então a data de início fica travada',
      () {
        expect(
          _vigencia(
            SituacaoVigencia.agendado,
            editavel: false,
          ).podeAlterarInicio,
          isFalse,
        );
      },
    );

    test('Cenário: Dado o código da API, quando procuro a situação, então acho a certa ou nula', () {
      expect(SituacaoVigencia.doCodigo('VIGENTE'), SituacaoVigencia.vigente);
      expect(SituacaoVigencia.doCodigo('AGENDADO'), SituacaoVigencia.agendado);
      expect(SituacaoVigencia.doCodigo('OUTRA'), isNull);
    });
  });

  group('Funcionalidade: data só de dia (RN24)', () {
    test('Cenário: Dado aaaa-mm-dd, quando leio, então vira meia-noite local daquele dia', () {
      expect(DataDia.ler('2026-01-05'), DateTime(2026, 1, 5));
    });

    test('Cenário: Dado um texto fora do formato, quando leio, então lança FormatException', () {
      for (final texto in ['05/01/2026', '2026-1-5', '2026-01-05T10:00']) {
        expect(() => DataDia.ler(texto), throwsFormatException, reason: texto);
      }
    });

    test(
      'Cenário: Dado uma data com hora, quando formato, então descarto a hora',
      () {
        final data = DateTime(2026, 1, 5, 23, 59);

        expect(DataDia.de(data), DateTime(2026, 1, 5));
        expect(DataDia.iso(data), '2026-01-05');
        expect(DataDia.curta(data), '05/01');
        expect(DataDia.completa(data), '05/01/2026');
      },
    );
  });
}
