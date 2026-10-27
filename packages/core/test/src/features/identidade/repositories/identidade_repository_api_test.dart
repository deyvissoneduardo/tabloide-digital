import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../../responses/identidade_response_test.dart' show corpoIdentidade;

class _RestClientMock extends Mock implements RestClient {}

const _caminho = '/painel/lojista/identidade';

const _pedido = IdentidadeRequest(
  nomeFantasia: 'Mercado Bom Preço',
  sePanfleto: true,
  corPrimaria: '#C8102E',
  corSecundaria: '#ffd100',
);

Map<String, Object?> _erro(
  String codigo,
  String mensagem, [
  Map<String, Object?>? detalhes,
]) => {
  'erro': {'codigo': codigo, 'mensagem': mensagem, 'detalhes': ?detalhes},
};

void main() {
  group('Funcionalidade: identidade visual na API', () {
    late _RestClientMock client;
    late IdentidadeRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = IdentidadeRepositoryApi(client);
    });

    RestResposta resposta(int status, [Object? dados]) =>
        RestResposta(status: status, dados: dados);

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    Future<RestResposta> enviarLogo() => client.enviarArquivo(
      '/painel/lojista/logo',
      campo: 'imagem',
      bytes: any(named: 'bytes'),
      nomeArquivo: any(named: 'nomeArquivo'),
    );

    test('Cenário: Dado a API com a identidade do lojista, quando obtenho, então recebo nome, cores e logo', () async {
      when(() => client.get(_caminho))
          .thenAnswer((_) async => resposta(200, corpoIdentidade()));

      expect(
        await repository.obter(),
        const Success<Falha, IdentidadeResponse>(identidadeFake),
      );
    });

    test('Cenário: Dado uma identidade fora do formato, quando obtenho, então recebo FalhaInesperada', () async {
      when(() => client.get(_caminho))
          .thenAnswer((_) async => resposta(200, {'nome': 'x'}));

      expect(falhaDe(await repository.obter()), isA<FalhaInesperada>());
    });

    test('Cenário: Dado a API sem conexão, quando obtenho, então recebo FalhaSemConexao', () async {
      when(() => client.get(_caminho)).thenThrow(const ErroSemConexao());

      expect(falhaDe(await repository.obter()), const FalhaSemConexao());
    });

    test('Cenário: Dado a API aceitando (200), quando edito, então envio o PATCH com o corpo e recebo a identidade', () async {
      when(() => client.patch(_caminho, corpo: any(named: 'corpo')))
          .thenAnswer((_) async => resposta(200, corpoIdentidade()));

      expect(
        await repository.editar(_pedido),
        const Success<Falha, IdentidadeResponse>(identidadeFake),
      );
      verify(() => client.patch(_caminho, corpo: _pedido.toJson())).called(1);
    });

    test('Cenário: Dado uma cor inválida (400), quando edito, então o erro vai para o campo corPrimaria', () async {
      when(() => client.patch(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => resposta(
          400,
          _erro('VALIDACAO_INVALIDA', 'Dados inválidos.', {
            'campos': {
              'corPrimaria': ['Informe a cor no formato #RRGGBB.'],
            },
          }),
        ),
      );

      expect(
        falhaDe(await repository.editar(_pedido)),
        const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'corPrimaria': ['Informe a cor no formato #RRGGBB.'],
          },
        ),
      );
    });

    test('Cenário: Dado uma imagem válida, quando envio o logo, então faço PUT multipart no campo imagem e recebo a identidade', () async {
      when(enviarLogo)
          .thenAnswer((_) async => resposta(200, corpoIdentidade()));

      expect(
        await repository.enviarLogo(bytes: [1, 2, 3], nomeArquivo: 'logo.jpg'),
        const Success<Falha, IdentidadeResponse>(identidadeFake),
      );
      verify(
        () => client.enviarArquivo(
          '/painel/lojista/logo',
          campo: 'imagem',
          bytes: [1, 2, 3],
          nomeArquivo: 'logo.jpg',
        ),
      ).called(1);
    });

    for (final (status, codigo, mensagem, detalhes) in [
      (
        422,
        'IMAGEM_INVALIDA',
        'Envie uma imagem JPEG, PNG ou WebP válida.',
        null,
      ),
      (
        413,
        'IMAGEM_MUITO_GRANDE',
        'A imagem é maior que o tamanho permitido.',
        {'maxBytes': 10485760},
      ),
    ]) {
      test(
        'Cenário: Dado a API recusando a imagem ($status), quando envio o logo, então recebo FalhaApi $codigo',
        () async {
          when(enviarLogo).thenAnswer(
            (_) async => resposta(status, _erro(codigo, mensagem, detalhes)),
          );

          expect(
            falhaDe(
              await repository.enviarLogo(bytes: [1], nomeArquivo: 'a.gif'),
            ),
            FalhaApi(codigo: codigo, mensagem: mensagem),
          );
        },
      );
    }

    test('Cenário: Dado um erro sem corpo, quando envio o logo, então recebo FalhaInesperada', () async {
      when(enviarLogo).thenAnswer((_) async => resposta(500));

      expect(
        falhaDe(await repository.enviarLogo(bytes: [1], nomeArquivo: 'a.png')),
        isA<FalhaInesperada>(),
      );
    });
  });
}
