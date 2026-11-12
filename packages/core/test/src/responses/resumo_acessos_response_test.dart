import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

Map<String, Object?> corpoResumoAcessos({Object? pico}) => {
  'intervalo': {'inicio': '2026-10-11', 'fim': '2026-11-09'},
  'total': 1840,
  'porFilial': [
    {'filialId': 'f1', 'nome': 'Centro', 'excluida': false, 'total': 1210},
    {'filialId': 'f3', 'nome': 'Loja antiga', 'excluida': true, 'total': 0},
  ],
  'porDia': [
    {'data': '2026-10-11', 'total': 41},
    {'data': '2026-10-12', 'total': 0},
  ],
  'iniciosPanfleto': [
    {'data': '2026-10-20', 'filialId': 'f1'},
  ],
  'pico':
      pico ??
      {
        'disponivel': true,
        'minimo': 100,
        'porHora': List.filled(24, 5),
        'porDiaSemana': [210, 190, 200, 230, 310, 400, 300],
      },
};

void main() {
  group('Funcionalidade: ler o resumo de acessos', () {
    test('Cenário: Dado o corpo 200 da API, quando leio, então todos os campos viram tipos do Dart', () {
      final resumo = ResumoAcessosResponse.fromJson(corpoResumoAcessos());

      expect(resumo.inicio, DateTime(2026, 10, 11));
      expect(resumo.fim, DateTime(2026, 11, 9));
      expect(resumo.total, 1840);
      expect(resumo.porFilial.map((f) => (f.nome, f.excluida, f.total)), [
        ('Centro', false, 1210),
        ('Loja antiga', true, 0),
      ]);
      expect(resumo.porDia.map((d) => (d.data, d.total)), [
        (DateTime(2026, 10, 11), 41),
        (DateTime(2026, 10, 12), 0),
      ]);
      expect(resumo.iniciosPanfleto.single.data, DateTime(2026, 10, 20));
      expect(resumo.pico.disponivel, isTrue);
      expect(resumo.pico.porHora, hasLength(24));
      expect(resumo.pico.porDiaSemana!.first, 210);
    });

    test('Cenário: Dado o pico indisponível, quando leio, então os vetores ficam nulos', () {
      final resumo = ResumoAcessosResponse.fromJson(
        corpoResumoAcessos(
          pico: {
            'disponivel': false,
            'minimo': 100,
            'porHora': null,
            'porDiaSemana': null,
          },
        ),
      );

      expect(resumo.pico.disponivel, isFalse);
      expect(resumo.pico.minimo, 100);
      expect(resumo.pico.porHora, isNull);
      expect(resumo.pico.porDiaSemana, isNull);
    });

    test('Cenário: Dado um vetor de horas com tamanho errado, quando leio, então recebo FormatException', () {
      expect(
        () => ResumoAcessosResponse.fromJson(
          corpoResumoAcessos(
            pico: {
              'disponivel': true,
              'minimo': 100,
              'porHora': List.filled(23, 1),
              'porDiaSemana': List.filled(7, 1),
            },
          ),
        ),
        throwsFormatException,
      );
    });

    test('Cenário: Dado um corpo sem intervalo, quando leio, então recebo FormatException', () {
      expect(
        () => ResumoAcessosResponse.fromJson({'total': 1}),
        throwsFormatException,
      );
    });
  });
}
