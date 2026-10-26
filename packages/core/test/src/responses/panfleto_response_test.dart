import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

Map<String, Object?> corpoPanfleto({
  String id = '0192f0c0-8e40-7d32-9f5c-3e4f5a6b7c03',
  String dataInicio = '2026-10-18',
  String? dataLimite = '2026-10-31',
  String situacao = 'VIGENTE',
}) => {
  'id': id,
  'filialId': '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  'urlImagem':
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/panfleto/0192f0c0.webp',
  'largura': 1600,
  'altura': 2263,
  'dataInicio': dataInicio,
  'dataLimite': dataLimite,
  'situacao': situacao,
  'editavel': true,
  'criadoEm': '2026-10-18T13:10:00.000Z',
  'excluidoEm': null,
};

void main() {
  group('Funcionalidade: ler e enviar panfleto', () {
    test('Cenário: Dado o corpo 200 da API, quando leio, então todos os campos viram tipos do Dart', () {
      expect(PanfletoResponse.fromJson(corpoPanfleto()), panfletoFake);
    });

    test('Cenário: Dado um panfleto agendado sem data limite, quando leio, então a vigência fica agendada e sem limite', () {
      final panfleto = PanfletoResponse.fromJson(
        corpoPanfleto(
          dataInicio: '2026-11-01',
          dataLimite: null,
          situacao: 'AGENDADO',
        ),
      );

      expect(panfleto.vigencia.situacao, SituacaoVigencia.agendado);
      expect(panfleto.vigencia.dataInicio, DateTime(2026, 11));
      expect(panfleto.vigencia.dataLimite, isNull);
    });

    test('Cenário: Dado um corpo sem campo obrigatório, quando leio, então lança FormatException', () {
      expect(
        () => PanfletoResponse.fromJson(
          {...corpoPanfleto()}..remove('urlImagem'),
        ),
        throwsFormatException,
      );
      expect(
        () =>
            PanfletoResponse.fromJson({...corpoPanfleto()}..remove('editavel')),
        throwsFormatException,
      );
    });

    test('Cenário: Dado uma situação desconhecida, quando leio, então lança FormatException', () {
      expect(
        () => PanfletoResponse.fromJson(corpoPanfleto(situacao: 'RASCUNHO')),
        throwsFormatException,
      );
    });

    test('Cenário: Dado uma data com hora, quando leio, então lança FormatException (vigência é só dia)', () {
      expect(
        () => PanfletoResponse.fromJson(
          corpoPanfleto(dataInicio: '2026-10-18T00:00:00Z'),
        ),
        throwsFormatException,
      );
    });

    test('Cenário: Dado um pedido com as duas datas, quando converto, então envio aaaa-mm-dd', () {
      final pedido = PanfletoRequest(
        dataInicio: DateTime(2026, 11, 1),
        dataLimite: DateTime(2027, 1, 15),
      );

      expect(pedido.toJson(), {
        'dataInicio': '2026-11-01',
        'dataLimite': '2027-01-15',
      });
    });

    test('Cenário: Dado um pedido sem datas, quando converto, então omito os campos', () {
      expect(const PanfletoRequest().toJson(), isEmpty);
    });
  });
}
