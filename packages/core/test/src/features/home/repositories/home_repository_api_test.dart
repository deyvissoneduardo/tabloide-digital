import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';

class _RestClientMock extends Mock implements RestClient {}

const _query = {'situacao': 'VIGENTE', 'pagina': 1, 'porPagina': 1};

Map<String, Object?> _pagina(int total) => {
  'itens': const [],
  'total': total,
  'pagina': 1,
  'porPagina': 1,
};

void main() {
  group('Funcionalidade: resumo da home na API', () {
    late _RestClientMock client;
    late HomeRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = HomeRepositoryApi(client);
    });

    void responder(String caminho, int total) => when(
      () => client.get(caminho, query: _query),
    ).thenAnswer((_) async => RestResposta(status: 200, dados: _pagina(total)));

    test('Cenário: Dado duas filiais, quando busco o resumo, então somo os vigentes de cada uma lendo só o total', () async {
      responder('/painel/filiais/f1/panfletos', 1);
      responder('/painel/filiais/f1/produtos', 12);
      responder('/painel/filiais/f2/panfletos', 0);
      responder('/painel/filiais/f2/produtos', 30);

      final resultado = await repository.buscarResumo(const ['f1', 'f2']);

      expect(
        resultado,
        const Success<Falha, ResumoPainel>(
          ResumoPainel(panfletosVigentes: 1, produtosVigentes: 42),
        ),
      );
    });

    test('Cenário: Dado nenhuma filial, quando busco o resumo, então recebo zeros sem chamar a API', () async {
      final resultado = await repository.buscarResumo(const []);

      expect(
        resultado,
        const Success<Falha, ResumoPainel>(
          ResumoPainel(panfletosVigentes: 0, produtosVigentes: 0),
        ),
      );
      verifyZeroInteractions(client);
    });

    test('Cenário: Dado falha em uma das contagens, quando busco o resumo, então recebo a falha', () async {
      responder('/painel/filiais/f1/panfletos', 1);
      when(() => client.get('/painel/filiais/f1/produtos', query: _query))
          .thenThrow(const ErroSemConexao());

      final resultado = await repository.buscarResumo(const ['f1']);

      expect(resultado, const Failure<Falha, ResumoPainel>(FalhaSemConexao()));
    });

    test('Cenário: Dado uma filial inexistente (404), quando busco o resumo, então recebo a FalhaApi', () async {
      when(() => client.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => const RestResposta(
          status: 404,
          dados: {
            'erro': {
              'codigo': 'RECURSO_NAO_ENCONTRADO',
              'mensagem': 'Não encontrado.',
            },
          },
        ),
      );

      final resultado = await repository.buscarResumo(const ['f1']);

      expect(
        resultado,
        const Failure<Falha, ResumoPainel>(
          FalhaApi(
            codigo: 'RECURSO_NAO_ENCONTRADO',
            mensagem: 'Não encontrado.',
          ),
        ),
      );
    });

    test('Cenário: Dado uma listagem sem total, quando busco o resumo, então recebo FalhaInesperada', () async {
      when(() => client.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => const RestResposta(status: 200, dados: {'itens': []}),
      );

      final resultado = await repository.buscarResumo(const ['f1']);

      expect(
        (resultado as Failure<Falha, ResumoPainel>).falha,
        isA<FalhaInesperada>(),
      );
    });
  });
}
