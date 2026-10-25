import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../../responses/filial_response_test.dart' show corpoFilial;

class _RestClientMock extends Mock implements RestClient {}

const _id = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

const _pedido = FilialRequest(
  nome: 'Centro',
  endereco: Endereco(
    cep: '13010-111',
    logradouro: 'Rua das Flores',
    numero: '120',
    complemento: 'Loja 2',
    bairro: 'Centro',
    cidade: 'Campinas',
    uf: 'SP',
  ),
  fusoHorario: 'America/Sao_Paulo',
);

Map<String, Object?> _erro(
  String codigo,
  String mensagem, [
  Map<String, Object?>? detalhes,
]) => {
  'erro': {'codigo': codigo, 'mensagem': mensagem, 'detalhes': ?detalhes},
};

void main() {
  group('Funcionalidade: filiais na API', () {
    late _RestClientMock client;
    late FilialRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = FilialRepositoryApi(client);
    });

    RestResposta resposta(int status, [Object? dados]) =>
        RestResposta(status: status, dados: dados);

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    test('Cenário: Dado a API com uma filial, quando listo, então peço a primeira página de 50 e recebo os itens', () async {
      when(
        () => client.get(
          '/painel/filiais',
          query: {'pagina': 1, 'porPagina': 50},
        ),
      ).thenAnswer(
        (_) async => resposta(200, {
          'itens': [corpoFilial()],
          'total': 1,
          'pagina': 1,
          'porPagina': 50,
        }),
      );

      final resultado = await repository.listar();

      expect(resultado.fold((_) => null, (lista) => lista), [filialFake]);
    });

    test('Cenário: Dado uma lista fora do formato, quando listo, então recebo FalhaInesperada', () async {
      when(() => client.get('/painel/filiais', query: any(named: 'query')))
          .thenAnswer((_) async => resposta(200, {'dados': []}));

      expect(falhaDe(await repository.listar()), isA<FalhaInesperada>());
    });

    test('Cenário: Dado uma filial existente, quando obtenho pelo id, então recebo a filial', () async {
      when(() => client.get('/painel/filiais/$_id'))
          .thenAnswer((_) async => resposta(200, corpoFilial()));

      expect(
        await repository.obter(_id),
        Success<Falha, FilialResponse>(filialFake),
      );
    });

    test('Cenário: Dado um id inexistente (404), quando obtenho, então recebo FalhaApi da API', () async {
      when(() => client.get('/painel/filiais/$_id')).thenAnswer(
        (_) async =>
            resposta(404, _erro('RECURSO_NAO_ENCONTRADO', 'Não encontrado.')),
      );

      expect(
        falhaDe(await repository.obter(_id)),
        const FalhaApi(
          codigo: 'RECURSO_NAO_ENCONTRADO',
          mensagem: 'Não encontrado.',
        ),
      );
    });

    test('Cenário: Dado a API criando (201), quando cadastro uma filial, então envio o corpo e recebo a filial', () async {
      when(() => client.post('/painel/filiais', corpo: any(named: 'corpo')))
          .thenAnswer((_) async => resposta(201, corpoFilial()));

      expect(
        await repository.criar(_pedido),
        Success<Falha, FilialResponse>(filialFake),
      );
      verify(() => client.post('/painel/filiais', corpo: _pedido.toJson()))
          .called(1);
    });

    test('Cenário: Dado o limite do plano (409), quando cadastro, então recebo FalhaApi sem erro de campo', () async {
      when(() => client.post('/painel/filiais', corpo: any(named: 'corpo')))
          .thenAnswer(
            (_) async => resposta(
              409,
              _erro(
                'LIMITE_DO_PLANO_ATINGIDO',
                'O limite do seu plano foi atingido.',
                {'recurso': 'FILIAIS', 'limite': 3},
              ),
            ),
          );

      expect(
        falhaDe(await repository.criar(_pedido)),
        const FalhaApi(
          codigo: 'LIMITE_DO_PLANO_ATINGIDO',
          mensagem: 'O limite do seu plano foi atingido.',
        ),
      );
    });

    test('Cenário: Dado um fuso inválido (422), quando cadastro, então o erro vai para o campo fusoHorario', () async {
      when(() => client.post('/painel/filiais', corpo: any(named: 'corpo')))
          .thenAnswer(
            (_) async => resposta(
              422,
              _erro('FUSO_HORARIO_INVALIDO', 'Fuso horário inválido.', {
                'campo': 'fusoHorario',
              }),
            ),
          );

      expect(
        falhaDe(await repository.criar(_pedido)),
        const FalhaApi(
          codigo: 'FUSO_HORARIO_INVALIDO',
          mensagem: 'Fuso horário inválido.',
          campos: {
            'fusoHorario': ['Fuso horário inválido.'],
          },
        ),
      );
    });

    test('Cenário: Dado dados inválidos (400) com detalhes por campo, quando cadastro, então recebo os erros de cada campo', () async {
      when(() => client.post('/painel/filiais', corpo: any(named: 'corpo')))
          .thenAnswer(
            (_) async => resposta(
              400,
              _erro('VALIDACAO_INVALIDA', 'Dados inválidos.', {
                'campos': {
                  'nome': ['Informe o nome.'],
                  'endereco.cep': ['CEP inválido.', 42],
                },
              }),
            ),
          );

      expect(
        falhaDe(await repository.criar(_pedido)),
        const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'nome': ['Informe o nome.'],
            'endereco.cep': ['CEP inválido.'],
          },
        ),
      );
    });

    test('Cenário: Dado uma filial existente, quando edito, então envio PATCH no id e recebo a filial', () async {
      when(
        () => client.patch('/painel/filiais/$_id', corpo: any(named: 'corpo')),
      ).thenAnswer((_) async => resposta(200, corpoFilial()));

      expect(
        await repository.editar(_id, _pedido),
        Success<Falha, FilialResponse>(filialFake),
      );
      verify(
        () => client.patch('/painel/filiais/$_id', corpo: _pedido.toJson()),
      ).called(1);
    });

    test('Cenário: Dado a API excluindo (204), quando excluo, então recebo Success', () async {
      when(() => client.delete('/painel/filiais/$_id'))
          .thenAnswer((_) async => resposta(204));

      expect((await repository.excluir(_id)).isSuccess, isTrue);
    });

    test('Cenário: Dado uma filial já excluída (404), quando excluo, então recebo FalhaApi', () async {
      when(() => client.delete('/painel/filiais/$_id')).thenAnswer(
        (_) async =>
            resposta(404, _erro('RECURSO_NAO_ENCONTRADO', 'Não encontrado.')),
      );

      expect(falhaDe(await repository.excluir(_id)), isA<FalhaApi>());
    });

    test('Cenário: Dado uma resposta de erro sem corpo, quando listo, então recebo FalhaInesperada', () async {
      when(() => client.get('/painel/filiais', query: any(named: 'query')))
          .thenAnswer((_) async => resposta(500));

      expect(falhaDe(await repository.listar()), isA<FalhaInesperada>());
    });

    test(
      'Cenário: Dado sem conexão, quando listo, então recebo FalhaSemConexao',
      () async {
        when(() => client.get('/painel/filiais', query: any(named: 'query')))
            .thenThrow(const ErroSemConexao());

        expect(falhaDe(await repository.listar()), const FalhaSemConexao());
      },
    );
  });
}
