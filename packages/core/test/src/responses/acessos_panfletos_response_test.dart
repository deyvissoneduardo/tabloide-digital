import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

Map<String, Object?> corpoAcessoPanfleto({
  String situacao = 'VIGENTE',
  String? dataLimite = '2026-11-15',
  num media = 46.7,
}) => {
  'panfletoId': 'p1',
  'dataInicio': '2026-10-20',
  'dataLimite': dataLimite,
  'dataFimContagem': '2026-11-09',
  'situacao': situacao,
  'totalAcessos': 980,
  'dias': 21,
  'mediaPorDia': media,
};

void main() {
  group('Funcionalidade: ler os acessos por panfleto', () {
    test('Cenário: Dado o corpo 200 da API, quando leio, então todos os campos viram tipos do Dart', () {
      final item = AcessosPanfletosResponse.fromJson({
        'itens': [corpoAcessoPanfleto()],
      }).itens.single;

      expect(item.panfletoId, 'p1');
      expect(item.dataInicio, DateTime(2026, 10, 20));
      expect(item.dataLimite, DateTime(2026, 11, 15));
      expect(item.dataFimContagem, DateTime(2026, 11, 9));
      expect(item.situacao, SituacaoAcessoPanfleto.vigente);
      expect(item.totalAcessos, 980);
      expect(item.dias, 21);
      expect(item.mediaPorDia, 46.7);
    });

    test('Cenário: Dado média inteira e sem data limite, quando leio, então a média vira double e o limite fica nulo', () {
      final item = AcessosPanfletoResponse.fromJson(
        corpoAcessoPanfleto(media: 47, dataLimite: null, situacao: 'EXCLUIDO'),
      );

      expect(item.mediaPorDia, 47.0);
      expect(item.dataLimite, isNull);
      expect(item.situacao, SituacaoAcessoPanfleto.excluido);
    });

    test('Cenário: Dado uma situação desconhecida, quando leio, então recebo FormatException', () {
      expect(
        () => AcessosPanfletoResponse.fromJson(
          corpoAcessoPanfleto(situacao: 'AGENDADO'),
        ),
        throwsFormatException,
      );
    });
  });
}
