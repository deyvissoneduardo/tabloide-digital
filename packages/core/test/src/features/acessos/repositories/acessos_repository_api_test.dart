import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';

import '../../../responses/acessos_panfletos_response_test.dart';
import '../../../responses/resumo_acessos_response_test.dart';

class _RestClientMock extends Mock implements RestClient {}

void main() {
  group('Funcionalidade: acessos na API', () {
    late _RestClientMock client;
    late AcessosRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = AcessosRepositoryApi(client);
    });

    void responder(String caminho, Map<String, dynamic> query, Object corpo) =>
        when(() => client.get(caminho, query: query))
            .thenAnswer((_) async => RestResposta(status: 200, dados: corpo));

    test('Cenário: Dado o período predefinido, quando busco o resumo, então chamo /painel/acessos só com periodo', () async {
      responder('/painel/acessos', {'periodo': 7}, corpoResumoAcessos());

      final resultado = await repository.resumo(const PeriodoPredefinido(7));

      expect(resultado, isA<Success<Falha, ResumoAcessosResponse>>());
      verify(() => client.get('/painel/acessos', query: {'periodo': 7}))
          .called(1);
    });

    test('Cenário: Dado período personalizado e filial, quando busco o resumo, então mando inicio, fim e filialId', () async {
      final query = {
        'inicio': '2026-10-01',
        'fim': '2026-10-31',
        'filialId': 'f1',
      };
      responder('/painel/acessos', query, corpoResumoAcessos());

      final resultado = await repository.resumo(
        PeriodoPersonalizado(DateTime(2026, 10, 1), DateTime(2026, 10, 31)),
        filialId: 'f1',
      );

      expect(resultado, isA<Success<Falha, ResumoAcessosResponse>>());
      verify(() => client.get('/painel/acessos', query: query)).called(1);
    });

    test('Cenário: Dado uma filial, quando busco os panfletos, então chamo a rota da filial com o período', () async {
      responder(
        '/painel/filiais/f1/acessos/panfletos',
        {'periodo': 30},
        {
          'itens': [corpoAcessoPanfleto()],
        },
      );

      final resultado = await repository.panfletos('f1', PeriodoAcessos.padrao);

      switch (resultado) {
        case Success(:final valor):
          expect(valor.itens.single.totalAcessos, 980);
        case Failure(:final falha):
          fail('esperava sucesso, veio $falha');
      }
    });

    test('Cenário: Dado 400 PERIODO_INVALIDO, quando busco o resumo, então recebo FalhaApi com o motivo', () async {
      when(() => client.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => const RestResposta(
          status: 400,
          dados: {
            'erro': {
              'codigo': 'PERIODO_INVALIDO',
              'mensagem': 'Período inválido.',
              'detalhes': {'motivo': 'ACIMA_DE_366_DIAS'},
            },
          },
        ),
      );

      final resultado = await repository.resumo(PeriodoAcessos.padrao);

      switch (resultado) {
        case Failure(falha: final FalhaApi falha):
          expect(falha.codigo, 'PERIODO_INVALIDO');
          expect(falha.mensagem, 'Período inválido.');
          expect(falha.detalhes, {'motivo': 'ACIMA_DE_366_DIAS'});
        case _:
          fail('esperava FalhaApi, veio $resultado');
      }
    });

    test('Cenário: Dado sem conexão, quando busco os panfletos, então recebo FalhaSemConexao', () async {
      when(() => client.get(any(), query: any(named: 'query')))
          .thenThrow(const ErroSemConexao());

      final resultado = await repository.panfletos('f1', PeriodoAcessos.padrao);

      expect(
        resultado,
        const Failure<Falha, AcessosPanfletosResponse>(FalhaSemConexao()),
      );
    });

    test('Cenário: Dado um corpo fora do formato, quando busco o resumo, então recebo FalhaInesperada', () async {
      responder('/painel/acessos', {'periodo': 30}, {'total': 1});

      final resultado = await repository.resumo(PeriodoAcessos.padrao);

      expect(
        resultado,
        isA<Failure<Falha, ResumoAcessosResponse>>().having(
          (f) => f.falha,
          'falha',
          isA<FalhaInesperada>(),
        ),
      );
    });
  });
}
