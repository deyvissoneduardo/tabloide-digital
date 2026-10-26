import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../../responses/categoria_response_test.dart' show corpoCategoria;

class _RestClientMock extends Mock implements RestClient {}

const _filial = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

const _caminho = '/painel/filiais/$_filial/categorias';

const _id = '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04';

void main() {
  group('Funcionalidade: categorias na API', () {
    late _RestClientMock client;
    late CategoriaRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = CategoriaRepositoryApi(client);
    });

    RestResposta resposta(int status, [Object? dados]) =>
        RestResposta(status: status, dados: dados);

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    test('Cenário: Dado a filial com categorias, quando listo, então recebo todas sem paginação', () async {
      when(() => client.get(_caminho)).thenAnswer(
        (_) async => resposta(200, {
          'itens': [corpoCategoria()],
        }),
      );

      final resultado = await repository.listar(_filial);

      expect(resultado.fold((_) => null, (lista) => lista), [categoriaFake]);
    });

    test('Cenário: Dado uma lista fora do formato, quando listo, então recebo FalhaInesperada', () async {
      when(() => client.get(_caminho))
          .thenAnswer((_) async => resposta(200, {'dados': []}));

      expect(falhaDe(await repository.listar(_filial)), isA<FalhaInesperada>());
    });

    test(
      'Cenário: Dado um nome novo, quando crio, então faço POST com o nome',
      () async {
        when(() => client.post(_caminho, corpo: {'nome': 'Mercearia'}))
            .thenAnswer((_) async => resposta(201, corpoCategoria()));

        expect(
          await repository.criar(
            _filial,
            const CategoriaRequest(nome: 'Mercearia'),
          ),
          Success<Falha, CategoriaResponse>(categoriaFake),
        );
      },
    );

    test('Cenário: Dado um nome repetido (409), quando crio, então recebo FalhaApi CATEGORIA_JA_EXISTE (RN43)', () async {
      when(() => client.post(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => resposta(409, {
          'erro': {
            'codigo': 'CATEGORIA_JA_EXISTE',
            'mensagem': 'Já existe uma categoria com esse nome nesta filial.',
          },
        }),
      );

      expect(
        falhaDe(
          await repository.criar(
            _filial,
            const CategoriaRequest(nome: 'mercearia'),
          ),
        ),
        const FalhaApi(
          codigo: 'CATEGORIA_JA_EXISTE',
          mensagem: 'Já existe uma categoria com esse nome nesta filial.',
        ),
      );
    });

    test('Cenário: Dado uma categoria, quando renomeio, então faço PATCH com o nome novo', () async {
      when(
        () => client.patch(
          '$_caminho/$_id',
          corpo: {'nome': 'Mercearia e Grãos'},
        ),
      ).thenAnswer(
        (_) async => resposta(200, corpoCategoria(nome: 'Mercearia e Grãos')),
      );

      final resultado = await repository.renomear(
        _filial,
        _id,
        const CategoriaRequest(nome: 'Mercearia e Grãos'),
      );

      expect(resultado.fold((_) => null, (c) => c.nome), 'Mercearia e Grãos');
    });

    test('Cenário: Dado uma categoria sem produtos ativos, quando excluo (204), então recebo Nada', () async {
      when(() => client.delete('$_caminho/$_id'))
          .thenAnswer((_) async => resposta(204));

      expect(
        await repository.excluir(_filial, _id),
        const Success<Falha, Nada>(Nada()),
      );
    });

    test('Cenário: Dado uma categoria com produtos ativos (409), quando excluo, então recebo a falha com as contagens nos detalhes (RN20)', () async {
      when(() => client.delete('$_caminho/$_id')).thenAnswer(
        (_) async => resposta(409, {
          'erro': {
            'codigo': 'CATEGORIA_COM_PRODUTOS_ATIVOS',
            'mensagem': 'Exclua os produtos vigentes e agendados antes de excluir a categoria.',
            'detalhes': {'vigentes': 2, 'agendados': 1},
          },
        }),
      );

      final falha = falhaDe(await repository.excluir(_filial, _id));

      expect(falha, isA<FalhaApi>());
      expect((falha as FalhaApi).codigo, 'CATEGORIA_COM_PRODUTOS_ATIVOS');
      expect(falha.detalhes, {'vigentes': 2, 'agendados': 1});
    });

    test('Cenário: Dado que estou sem internet, quando listo, então recebo FalhaSemConexao', () async {
      when(() => client.get(_caminho)).thenThrow(const ErroSemConexao());

      expect(
        falhaDe(await repository.listar(_filial)),
        const FalhaSemConexao(),
      );
    });
  });
}
