import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

class _RestClientMock extends Mock implements RestClient {}

const _corpoSe = {
  'cep': '01001-000',
  'logradouro': 'Praça da Sé',
  'complemento': 'lado ímpar',
  'unidade': '',
  'bairro': 'Sé',
  'localidade': 'São Paulo',
  'uf': 'SP',
  'estado': 'São Paulo',
  'regiao': 'Sudeste',
  'ibge': '3550308',
  'gia': '1004',
  'ddd': '11',
  'siafi': '7107',
};

void main() {
  group('Funcionalidade: busca de CEP no ViaCEP', () {
    late _RestClientMock client;
    late CepRepositoryViaCep repository;

    setUp(() {
      client = _RestClientMock();
      repository = CepRepositoryViaCep(client);
    });

    void responder(int status, Object? dados) => when(
      () => client.get('/01001000/json/'),
    ).thenAnswer((_) async => RestResposta(status: status, dados: dados));

    test('Cenário: Dado um CEP existente, quando busco, então recebo rua, bairro, cidade e UF', () async {
      responder(200, _corpoSe);

      expect(
        await repository.buscar('01001000'),
        const Success<Falha, CepResponse>(cepFake),
      );
    });

    for (final (caso, status, dados) in [
      ('inexistente (erro "true")', 200, {'erro': 'true'}),
      ('inexistente (erro true)', 200, {'erro': true}),
      ('com formato inválido (400)', 400, null),
    ]) {
      test(
        'Cenário: Dado um CEP $caso, quando busco, então recebo CEP não encontrado',
        () async {
          responder(status, dados);

          expect(
            await repository.buscar('01001000'),
            const Failure<Falha, CepResponse>(cepNaoEncontrado),
          );
        },
      );
    }

    test('Cenário: Dado o ViaCEP fora do ar (500), quando busco, então recebo FalhaInesperada', () async {
      responder(500, null);

      final resultado = await repository.buscar('01001000');

      expect(resultado.fold((f) => f, (_) => null), isA<FalhaInesperada>());
    });

    test(
      'Cenário: Dado sem conexão, quando busco, então recebo FalhaSemConexao',
      () async {
        when(() => client.get('/01001000/json/'))
            .thenThrow(const ErroSemConexao());

        expect(
          await repository.buscar('01001000'),
          const Failure<Falha, CepResponse>(FalhaSemConexao()),
        );
      },
    );

    test('Cenário: Dado o fake, quando busco um CEP conhecido e um desconhecido, então registro as buscas', () async {
      final fake = CepRepositoryFake();

      expect(await fake.buscar('01001000'), isA<Success<Falha, CepResponse>>());
      expect(
        await fake.buscar('99999999'),
        const Failure<Falha, CepResponse>(cepNaoEncontrado),
      );
      fake.falhaSimulada = const FalhaSemConexao();
      expect(
        await fake.buscar('01001000'),
        const Failure<Falha, CepResponse>(FalhaSemConexao()),
      );
      expect(fake.buscados, ['01001000', '99999999', '01001000']);
    });
  });

  group('Funcionalidade: estados e fuso horário', () {
    test(
      'Cenário: Dado as 27 UFs, então cada uma tem nome e um fuso do Brasil',
      () {
        expect(Uf.values, hasLength(27));
        expect(Uf.values.map((uf) => uf.sigla).toSet(), hasLength(27));
      },
    );

    for (final (sigla, fuso) in [
      ('sp', 'America/Sao_Paulo'),
      ('AM', 'America/Manaus'),
      ('MT', 'America/Cuiaba'),
      ('AC', 'America/Rio_Branco'),
      ('PE', 'America/Recife'),
    ]) {
      test('Cenário: Dado a UF $sigla, então o fuso é $fuso', () {
        expect(Uf.daSigla(sigla)?.fuso.id, fuso);
      });
    }

    test('Cenário: Dado uma sigla que não existe, então não há UF', () {
      expect(Uf.daSigla('XX'), isNull);
    });
  });
}
