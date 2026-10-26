import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../../responses/panfleto_response_test.dart' show corpoPanfleto;

class _RestClientMock extends Mock implements RestClient {}

const _filial = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

const _caminho = '/painel/filiais/$_filial/panfletos';

const _id = '0192f0c0-8e40-7d32-9f5c-3e4f5a6b7c03';

Map<String, Object?> _erro(
  String codigo,
  String mensagem, [
  Map<String, Object?>? detalhes,
]) => {
  'erro': {'codigo': codigo, 'mensagem': mensagem, 'detalhes': ?detalhes},
};

void main() {
  group('Funcionalidade: panfletos na API', () {
    late _RestClientMock client;
    late PanfletoRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = PanfletoRepositoryApi(client);
    });

    RestResposta resposta(int status, [Object? dados]) =>
        RestResposta(status: status, dados: dados);

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    Future<RestResposta> enviarArquivo({MetodoEnvio? metodo}) =>
        client.enviarArquivo(
          any(),
          campo: any(named: 'campo'),
          bytes: any(named: 'bytes'),
          nomeArquivo: any(named: 'nomeArquivo'),
          metodo: metodo ?? any(named: 'metodo'),
          campos: any(named: 'campos'),
        );

    setUpAll(() => registerFallbackValue(MetodoEnvio.put));

    test('Cenário: Dado a filial com panfletos, quando listo, então peço só vigentes e agendados da primeira página de 50', () async {
      when(
        () => client.get(
          _caminho,
          query: {'situacao': 'VIGENTE,AGENDADO', 'pagina': 1, 'porPagina': 50},
        ),
      ).thenAnswer(
        (_) async => resposta(200, {
          'itens': [corpoPanfleto()],
          'total': 1,
          'pagina': 1,
          'porPagina': 50,
        }),
      );

      final resultado = await repository.listar(_filial);

      expect(resultado.fold((_) => null, (lista) => lista), [panfletoFake]);
    });

    test('Cenário: Dado uma lista fora do formato, quando listo, então recebo FalhaInesperada', () async {
      when(() => client.get(_caminho, query: any(named: 'query')))
          .thenAnswer((_) async => resposta(200, {'dados': []}));

      expect(falhaDe(await repository.listar(_filial)), isA<FalhaInesperada>());
    });

    test('Cenário: Dado um panfleto existente, quando obtenho pelo id, então recebo o panfleto', () async {
      when(() => client.get('$_caminho/$_id'))
          .thenAnswer((_) async => resposta(200, corpoPanfleto()));

      expect(
        await repository.obter(_filial, _id),
        Success<Falha, PanfletoResponse>(panfletoFake),
      );
    });

    test('Cenário: Dado um id inexistente (404), quando obtenho, então recebo FalhaApi', () async {
      when(() => client.get('$_caminho/$_id')).thenAnswer(
        (_) async =>
            resposta(404, _erro('RECURSO_NAO_ENCONTRADO', 'Não encontrado.')),
      );

      expect(
        falhaDe(await repository.obter(_filial, _id)),
        const FalhaApi(
          codigo: 'RECURSO_NAO_ENCONTRADO',
          mensagem: 'Não encontrado.',
        ),
      );
    });

    test('Cenário: Dado uma imagem e datas, quando cadastro, então faço POST multipart com a imagem e as datas no mesmo formulário', () async {
      when(enviarArquivo)
          .thenAnswer((_) async => resposta(201, corpoPanfleto()));

      final resultado = await repository.criar(
        _filial,
        PanfletoRequest(
          dataInicio: DateTime(2026, 10, 18),
          dataLimite: DateTime(2026, 10, 31),
        ),
        bytes: [1, 2, 3],
        nomeArquivo: 'panfleto.jpg',
      );

      expect(resultado, Success<Falha, PanfletoResponse>(panfletoFake));
      verify(
        () => client.enviarArquivo(
          _caminho,
          campo: 'imagem',
          bytes: [1, 2, 3],
          nomeArquivo: 'panfleto.jpg',
          metodo: MetodoEnvio.post,
          campos: {'dataInicio': '2026-10-18', 'dataLimite': '2026-10-31'},
        ),
      ).called(1);
    });

    for (final (codigo, mensagem, detalhes) in [
      (
        'PANFLETO_PERIODO_SOBREPOSTO',
        'Já existe um panfleto nesse período.',
        <String, Object?>{
          'conflitoCom': {
            'id': _id,
            'dataInicio': '2026-10-18',
            'dataLimite': '2026-10-31',
          },
        },
      ),
      (
        'PANFLETO_ATUAL_SEM_DATA_LIMITE',
        'Defina uma data limite no panfleto atual antes de agendar o próximo.',
        null,
      ),
    ]) {
      test(
        'Cenário: Dado a API recusando com 409 $codigo, quando cadastro, então recebo FalhaApi sem erro de campo e com os detalhes da API',
        () async {
          when(enviarArquivo).thenAnswer(
            (_) async => resposta(409, _erro(codigo, mensagem, detalhes)),
          );

          final falha = falhaDe(
            await repository.criar(
              _filial,
              const PanfletoRequest(),
              bytes: [1],
              nomeArquivo: 'p.jpg',
            ),
          );

          expect(falha, FalhaApi(codigo: codigo, mensagem: mensagem));
          expect((falha as FalhaApi).detalhes, detalhes ?? isEmpty);
        },
      );
    }

    test('Cenário: Dado uma data limite inválida (422), quando cadastro, então o erro vai para o campo dataLimite', () async {
      const mensagem =
          'A data limite não pode ser anterior à data de início nem a hoje.';
      when(enviarArquivo).thenAnswer(
        (_) async => resposta(
          422,
          _erro('DATA_LIMITE_INVALIDA', mensagem, {'campo': 'dataLimite'}),
        ),
      );

      expect(
        falhaDe(
          await repository.criar(
            _filial,
            const PanfletoRequest(),
            bytes: [1],
            nomeArquivo: 'p.jpg',
          ),
        ),
        const FalhaApi(
          codigo: 'DATA_LIMITE_INVALIDA',
          mensagem: mensagem,
          campos: {
            'dataLimite': [mensagem],
          },
        ),
      );
    });

    test('Cenário: Dado uma nova data limite, quando edito, então faço PATCH só com ela', () async {
      when(() => client.patch('$_caminho/$_id', corpo: any(named: 'corpo')))
          .thenAnswer(
            (_) async => resposta(200, corpoPanfleto(dataLimite: '2027-01-15')),
          );

      final resultado = await repository.editar(
        _filial,
        _id,
        PanfletoRequest(dataLimite: DateTime(2027, 1, 15)),
      );

      expect(
        resultado.fold((_) => null, (p) => p.vigencia.dataLimite),
        DateTime(2027, 1, 15),
      );
      verify(
        () =>
            client.patch('$_caminho/$_id', corpo: {'dataLimite': '2027-01-15'}),
      ).called(1);
    });

    test('Cenário: Dado um panfleto vigente (409 DATA_INICIO_IMUTAVEL), quando edito o início, então o erro vai para o campo dataInicio', () async {
      const mensagem =
          'A data de início de um item já vigente não pode ser alterada.';
      when(() => client.patch('$_caminho/$_id', corpo: any(named: 'corpo')))
          .thenAnswer(
            (_) async => resposta(
              409,
              _erro('DATA_INICIO_IMUTAVEL', mensagem, {'campo': 'dataInicio'}),
            ),
          );

      expect(
        falhaDe(
          await repository.editar(
            _filial,
            _id,
            PanfletoRequest(dataInicio: DateTime(2026, 10, 20)),
          ),
        ),
        const FalhaApi(
          codigo: 'DATA_INICIO_IMUTAVEL',
          mensagem: mensagem,
          campos: {
            'dataInicio': [mensagem],
          },
        ),
      );
    });

    test('Cenário: Dado uma nova imagem, quando troco a imagem, então faço PUT multipart em /imagem', () async {
      when(enviarArquivo)
          .thenAnswer((_) async => resposta(200, corpoPanfleto()));

      expect(
        await repository.trocarImagem(
          _filial,
          _id,
          bytes: [4, 5],
          nomeArquivo: 'novo.png',
        ),
        Success<Falha, PanfletoResponse>(panfletoFake),
      );
      verify(
        () => client.enviarArquivo(
          '$_caminho/$_id/imagem',
          campo: 'imagem',
          bytes: [4, 5],
          nomeArquivo: 'novo.png',
        ),
      ).called(1);
    });

    test('Cenário: Dado um panfleto vencido (409 ITEM_NAO_EDITAVEL), quando troco a imagem, então recebo FalhaApi', () async {
      when(enviarArquivo).thenAnswer(
        (_) async => resposta(
          409,
          _erro(
            'ITEM_NAO_EDITAVEL',
            'Itens vencidos ou excluídos não podem ser alterados.',
          ),
        ),
      );

      expect(
        falhaDe(
          await repository.trocarImagem(
            _filial,
            _id,
            bytes: [1],
            nomeArquivo: 'p.jpg',
          ),
        ),
        const FalhaApi(
          codigo: 'ITEM_NAO_EDITAVEL',
          mensagem: 'Itens vencidos ou excluídos não podem ser alterados.',
        ),
      );
    });

    test(
      'Cenário: Dado um panfleto, quando excluo (204), então recebo Nada',
      () async {
        when(() => client.delete('$_caminho/$_id'))
            .thenAnswer((_) async => resposta(204));

        expect(
          await repository.excluir(_filial, _id),
          const Success<Falha, Nada>(Nada()),
        );
      },
    );

    test('Cenário: Dado a API fora do ar, quando listo, então recebo FalhaSemConexao', () async {
      when(() => client.get(_caminho, query: any(named: 'query')))
          .thenThrow(const ErroSemConexao());

      expect(
        falhaDe(await repository.listar(_filial)),
        const FalhaSemConexao(),
      );
    });
  });
}
